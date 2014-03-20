/* -*- mode: c; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: t -*-
 * vim: ts=4 sw=4 noet ai cindent syntax=c
 *
 * Conky, a system monitor, based on torsmo
 *
 * Any original torsmo code is licensed under the BSD license
 *
 * All code written since the fork of torsmo is licensed under the GPL
 *
 * Please see COPYING for details
 *
 * Copyright (c) 2005-2010 Brenden Matthews, Philip Kovacs, et. al.
 *	(see AUTHORS)
 * All rights reserved.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#include "conky.h"
#include "logging.h"
#include "timed_thread.h"
#include "timeinfo.h"
#include "libmpdclient.h"
#include "mpd.h"

/* server connection data */
static char mpd_host[128];
static char mpd_password[128];
static int mpd_port;

/* this is >0 if the current password was set from MPD_HOST */
static int mpd_environment_password = 0;

/* global mpd information */
static struct mpd_s mpd_info;

/* number of users of the above struct */
static int refcount = 0;

void mpd_set_host(const char *host)
{
	snprintf(mpd_host, 128, "%s", host);

	if (mpd_environment_password) {
		/* for security, dont use environment password when user specifies host in config */
		mpd_clear_password();
	}
}
void mpd_set_password(const char *password, int from_environment)
{
	snprintf(mpd_password, 128, "%s", password);
	mpd_environment_password = from_environment;
}
void mpd_clear_password(void)
{
	*mpd_password = '\0';
	mpd_environment_password = 0;
}
int mpd_set_port(const char *port)
{
	int val;

	val = strtol(port, 0, 0);
	if (val < 1 || val > 0xffff)
		return 1;
	mpd_port = val;
	return 0;
}

void init_mpd(void)
{
	if (!(refcount++))	/* first client */
		memset(&mpd_info, 0, sizeof(mpd_info));
}

struct mpd_s *mpd_get_info(void)
{
	return &mpd_info;
}

static void clear_mpd(void)
{
#define xfree(x) if (x) free(x)
	xfree(mpd_info.title);
	xfree(mpd_info.artist);
	xfree(mpd_info.album);
	xfree(mpd_info.date);
	/* do not free() the const char *status! */
	/* do not free() the const char *random! */
	/* do not free() the const char *repeat! */
	xfree(mpd_info.track);
	xfree(mpd_info.name);
	xfree(mpd_info.file);
#undef xfree
	memset(&mpd_info, 0, sizeof(struct mpd_s));
}

void free_mpd(void)
{
	if (!(--refcount))	/* last client */
		clear_mpd();
}

static void *update_mpd_thread(void *) __attribute__((noreturn));

int update_mpd(void)
{
	int interval;
	static timed_thread *thread = NULL;

	if (thread)
		return 0;

	interval = info.music_player_interval * 1000000;
	thread = timed_thread_create(&update_mpd_thread, &thread, interval);
	if (!thread) {
		NORM_ERR("Failed to create MPD timed thread");
		return 0;
	}
	timed_thread_register(thread, &thread);
	if (timed_thread_run(thread))
		NORM_ERR("Failed to run MPD timed thread");
	return 0;
}

/* stringMAXdup dups at most text_buffer_size bytes */
#define strmdup(x) strndup(x, text_buffer_size - 1)

static void *update_mpd_thread(void *arg)
{
	static mpd_Connection *conn = NULL;
	mpd_Status *status;
	mpd_InfoEntity *entity;
	timed_thread *me = *(timed_thread **)arg;
	const char *emptystr = "";

	while (1) {
		if (!conn)
			conn = mpd_newConnection(mpd_host, mpd_port, 10);

		if (*mpd_password) {
			mpd_sendPasswordCommand(conn, mpd_password);
			mpd_finishCommand(conn);
		}

		timed_thread_lock(me);

		if (conn->error || conn == NULL) {
			NORM_ERR("MPD error: %s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			clear_mpd();

			mpd_info.status = "MPD not responding";
			timed_thread_unlock(me);
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}

		mpd_sendStatusCommand(conn);
		if ((status = mpd_getStatus(conn)) == NULL) {
			NORM_ERR("MPD error: %s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			clear_mpd();

			mpd_info.status = "MPD not responding";
			timed_thread_unlock(me);
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}
		mpd_finishCommand(conn);
		if (conn->error) {
			// fprintf(stderr, "%s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			timed_thread_unlock(me);
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}

		mpd_info.vol = status->volume;
		if (status->random == 0) {
			mpd_info.random = "Off";
		} else if (status->random == 1) {
			mpd_info.random = "On";
		} else {
			mpd_info.random = "";
		}
		if (status->repeat == 0) {
			mpd_info.repeat = "Off";
		} else if (status->repeat == 1) {
			mpd_info.repeat = "On";
		} else {
			mpd_info.repeat = "";
		}
		/* if (status->error) {
			printf("error: %s\n", status->error);
		} */

		switch (status->state) {
			case MPD_STATUS_STATE_PLAY:
				mpd_info.status = "Playing";
				break;
			case MPD_STATUS_STATE_STOP:
				mpd_info.status = "Stopped";
				break;
			case MPD_STATUS_STATE_PAUSE:
				mpd_info.status = "Paused";
				break;
			default:
				mpd_info.status = "";
				clear_mpd();
				break;
		}

		if (status->state == MPD_STATUS_STATE_PLAY ||
		    status->state == MPD_STATUS_STATE_PAUSE) {
			mpd_info.is_playing = 1;
			mpd_info.bitrate = status->bitRate;
			mpd_info.progress = (float) status->elapsedTime /
				status->totalTime;
			mpd_info.elapsed = status->elapsedTime;
			mpd_info.length = status->totalTime;
		} else {
			mpd_info.progress = 0;
			mpd_info.is_playing = 0;
			mpd_info.elapsed = 0;
		}

		if (conn->error) {
			// fprintf(stderr, "%s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			timed_thread_unlock(me);
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}

		mpd_sendCurrentSongCommand(conn);
		while ((entity = mpd_getNextInfoEntity(conn))) {
			mpd_Song *song = entity->info.song;

			if (entity->type != MPD_INFO_ENTITY_TYPE_SONG) {
				mpd_freeInfoEntity(entity);
				continue;
			}
#define SONGSET(x) {                            \
	free(mpd_info.x);                       \
	if(song->x)                             \
		mpd_info.x = strmdup(song->x);  \
	else                                    \
		mpd_info.x = strmdup(emptystr); \
}
			SONGSET(artist);
			SONGSET(album);
			SONGSET(title);
			SONGSET(date);
			SONGSET(track);
			SONGSET(name);
			SONGSET(file);
#undef SONGSET
			if (entity != NULL) {
				mpd_freeInfoEntity(entity);
				entity = NULL;
			}
		}
		mpd_finishCommand(conn);
		if (conn->error) {
			// fprintf(stderr, "%s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			timed_thread_unlock(me);
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}

		timed_thread_unlock(me);
		if (conn->error) {
			// fprintf(stderr, "%s\n", conn->errorStr);
			mpd_closeConnection(conn);
			conn = 0;
			if (timed_thread_test(me, 0)) {
				timed_thread_exit(me);
			}
			continue;
		}

		mpd_freeStatus(status);
		/* if (conn) {
			mpd_closeConnection(conn);
			conn = 0;
		} */
		if (timed_thread_test(me, 0)) {
			timed_thread_exit(me);
		}
		continue;
	}
	/* never reached */
}

static inline void format_media_player_time(char *buf, const int size,
		int seconds)
{
	int days, hours, minutes;

	if (times_in_seconds()) {
		snprintf(buf, size, "%d", seconds);
		return;
	}

	days = seconds / (24 * 60 * 60);
	seconds %= (24 * 60 * 60);
	hours = seconds / (60 * 60);
	seconds %= (60 * 60);
	minutes = seconds / 60;
	seconds %= 60;

	if (days > 0) {
		snprintf(buf, size, "%i days %i:%02i:%02i", days,
				hours, minutes, seconds);
	} else if (hours > 0) {
		snprintf(buf, size, "%i:%02i:%02i", hours, minutes,
				seconds);
	} else {
		snprintf(buf, size, "%i:%02i", minutes, seconds);
	}
}

void print_mpd_elapsed(struct text_object *obj, char *p, int p_max_size)
{
	(void)obj;
	format_media_player_time(p, p_max_size, mpd_get_info()->elapsed);
}

void print_mpd_length(struct text_object *obj, char *p, int p_max_size)
{
	(void)obj;
	format_media_player_time(p, p_max_size, mpd_get_info()->length);
}

void print_mpd_percent(struct text_object *obj, char *p, int p_max_size)
{
	(void)obj;
	percent_print(p, p_max_size, (int)(mpd_get_info()->progress * 100));
}

void print_mpd_bar(struct text_object *obj, char *p, int p_max_size)
{
	new_bar(obj, p, p_max_size, (int) (mpd_get_info()->progress * 255.0f));
}

void print_mpd_smart(struct text_object *obj, char *p, int p_max_size)
{
	struct mpd_s *mpd = mpd_get_info();
	int len = obj->data.i;
	if (len == 0 || len > p_max_size)
		len = p_max_size;

	memset(p, 0, p_max_size);
	if (mpd->artist && *mpd->artist &&
			mpd->title && *mpd->title) {
		snprintf(p, len, "%s - %s", mpd->artist,
				mpd->title);
	} else if (mpd->title && *mpd->title) {
		snprintf(p, len, "%s", mpd->title);
	} else if (mpd->artist && *mpd->artist) {
		snprintf(p, len, "%s", mpd->artist);
	} else if (mpd->file && *mpd->file) {
		snprintf(p, len, "%s", mpd->file);
	} else {
		*p = 0;
	}
}

#define MPD_PRINT_GENERATOR(name, fmt) \
void print_mpd_##name(struct text_object *obj, char *p, int p_max_size) \
{ \
	if (obj->data.i && obj->data.i < p_max_size) \
		p_max_size = obj->data.i; \
	snprintf(p, p_max_size, fmt, mpd_get_info()->name); \
}

MPD_PRINT_GENERATOR(title, "%s")
MPD_PRINT_GENERATOR(artist, "%s")
MPD_PRINT_GENERATOR(album, "%s")
MPD_PRINT_GENERATOR(date, "%s")
MPD_PRINT_GENERATOR(random, "%s")
MPD_PRINT_GENERATOR(repeat, "%s")
MPD_PRINT_GENERATOR(track, "%s")
MPD_PRINT_GENERATOR(name, "%s")
MPD_PRINT_GENERATOR(file, "%s")
MPD_PRINT_GENERATOR(vol, "%d")
MPD_PRINT_GENERATOR(bitrate, "%d")
MPD_PRINT_GENERATOR(status, "%s")

#undef MPD_PRINT_GENERATOR
