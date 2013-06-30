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
 * Copyright (c) 2004, Hannu Saransaari and Lauri Hakkarainen
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
#include "text_object.h"
#include <netdb.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netinet/in.h>

struct read_tcp_data {
	char *host;
	unsigned int port;
};

void parse_read_tcp_arg(struct text_object *obj, const char *arg, void *free_at_crash)
{
	struct read_tcp_data *rtd;

	rtd = malloc(sizeof(struct read_tcp_data));
	memset(rtd, 0, sizeof(struct read_tcp_data));

	rtd->host = malloc(text_buffer_size);
	sscanf(arg, "%s", rtd->host);
	sscanf(arg+strlen(rtd->host), "%u", &(rtd->port));
	if(rtd->port == 0) {
		rtd->port = atoi(rtd->host);
		strcpy(rtd->host,"localhost");
	}
	if(rtd->port < 1 || rtd->port > 65535)
		CRIT_ERR(obj, free_at_crash, "read_tcp: Needs \"(host) port\" as argument(s)");

	rtd->port = htons(rtd->port);
	obj->data.opaque = rtd;
}

void print_read_tcp(struct text_object *obj, char *p, int p_max_size)
{
	int sock, received;
	fd_set readfds;
	struct timeval tv;
	struct read_tcp_data *rtd = obj->data.opaque;
	struct addrinfo hints;
	struct addrinfo* airesult, *rp;
	char portbuf[8];

	if (!rtd)
		return;

	memset(&hints, 0, sizeof(struct addrinfo));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = 0;
	hints.ai_protocol = 0;
	snprintf(portbuf, 8, "%d", rtd->port);
	if (getaddrinfo(rtd->host, portbuf, &hints, &airesult)) {
		NORM_ERR("read_tcp: Problem with resolving the hostname");
		return;
	}
	for (rp = airesult; rp != NULL; rp = rp->ai_next) {
		sock = socket(rp->ai_family, rp->ai_socktype, rp->ai_protocol);
		if (sock == -1) {
			continue;
		}
		if (connect(sock, rp->ai_addr, rp->ai_addrlen) != -1) {
			break;
		}
		close(sock);
	}
	freeaddrinfo(airesult);
	if (rp == NULL) {
		NORM_ERR("read_tcp: Couldn't create a connection");
		return;
	}
	FD_ZERO(&readfds);
	FD_SET(sock, &readfds);
	tv.tv_sec = 1;
	tv.tv_usec = 0;
	if(select(sock + 1, &readfds, NULL, NULL, &tv) > 0){
		received = recv(sock, p, p_max_size, 0);
		p[received] = 0;
	}
	close(sock);
}

void free_read_tcp(struct text_object *obj)
{
	struct read_tcp_data *rtd = obj->data.opaque;

	if (!rtd)
		return;

	if (rtd->host)
		free(rtd->host);
	free(obj->data.opaque);
	obj->data.opaque = NULL;
}
