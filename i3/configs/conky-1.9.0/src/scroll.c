/* -*- mode: c; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: t -*-
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
#include "core.h"
#include "logging.h"
#include "specials.h"
#include "text_object.h"

struct scroll_data {
	char *text;
	unsigned int show;
	unsigned int step;
	unsigned int start;
	long resetcolor;
};

void parse_scroll_arg(struct text_object *obj, const char *arg, void *free_at_crash)
{
	struct scroll_data *sd;
	int n1 = 0, n2 = 0;

	sd = malloc(sizeof(struct scroll_data));
	memset(sd, 0, sizeof(struct scroll_data));

	sd->resetcolor = get_current_text_color();
	sd->step = 1;
	if (!arg || sscanf(arg, "%u %n", &sd->show, &n1) <= 0)
		CRIT_ERR(obj, free_at_crash, "scroll needs arguments: <length> [<step>] <text>");

	sscanf(arg + n1, "%u %n", &sd->step, &n2);
	if (*(arg + n1 + n2)) {
		n1 += n2;
	} else {
		sd->step = 1;
	}
	sd->text = malloc(strlen(arg + n1) + sd->show + 1);

	if (strlen(arg) > sd->show) {
		for(n2 = 0; (unsigned int) n2 < sd->show; n2++) {
		    sd->text[n2] = ' ';
		}
		sd->text[n2] = 0;
	}
	else
	    sd->text[0] = 0;

	strcat(sd->text, arg + n1);
	sd->start = 0;
	obj->sub = malloc(sizeof(struct text_object));
	extract_variable_text_internal(obj->sub, sd->text);

	obj->data.opaque = sd;
}

void print_scroll(struct text_object *obj, char *p, int p_max_size, struct information *cur)
{
	struct scroll_data *sd = obj->data.opaque;
	unsigned int j, colorchanges = 0, frontcolorchanges = 0, visibcolorchanges = 0, strend;
	char *pwithcolors;
	char buf[max_user_text];

	if (!sd)
		return;

	generate_text_internal(buf, max_user_text, *obj->sub, cur);
	for(j = 0; buf[j] != 0; j++) {
		switch(buf[j]) {
			case '\n':	//place all the lines behind each other with LINESEPARATOR between them
#define LINESEPARATOR '|'
				buf[j]=LINESEPARATOR;
				break;
			case SPECIAL_CHAR:
				colorchanges++;
				break;
		}
	}
	//no scrolling necessary if the length of the text to scroll is too short
	if (strlen(buf) - colorchanges <= sd->show) {
		snprintf(p, p_max_size, "%s", buf);
		return;
	}
	//make sure a colorchange at the front is not part of the string we are going to show
	while(*(buf + sd->start) == SPECIAL_CHAR) {
		sd->start++;
	}
	//place all chars that should be visible in p, including colorchanges
	for(j=0; j < sd->show + visibcolorchanges; j++) {
		p[j] = *(buf + sd->start + j);
		if(p[j] == SPECIAL_CHAR) {
			visibcolorchanges++;
		}
		//if there is still room fill it with spaces
		if( ! p[j]) break;
	}
	for(; j < sd->show + visibcolorchanges; j++) {
		p[j] = ' ';
	}
	p[j] = 0;
	//count colorchanges in front of the visible part and place that many colorchanges in front of the visible part
	for(j = 0; j < sd->start; j++) {
		if(buf[j] == SPECIAL_CHAR) frontcolorchanges++;
	}
	pwithcolors=malloc(strlen(p) + 1 + colorchanges - visibcolorchanges);
	for(j = 0; j < frontcolorchanges; j++) {
		pwithcolors[j] = SPECIAL_CHAR;
	}
	pwithcolors[j] = 0;
	strcat(pwithcolors,p);
	strend = strlen(pwithcolors);
	//and place the colorchanges not in front or in the visible part behind the visible part
	for(j = 0; j < colorchanges - frontcolorchanges - visibcolorchanges; j++) {
		pwithcolors[strend + j] = SPECIAL_CHAR;
	}
	pwithcolors[strend + j] = 0;
	strcpy(p, pwithcolors);
	free(pwithcolors);
	//scroll
	sd->start += sd->step;
	if(buf[sd->start] == 0 || sd->start > strlen(buf)){
		sd->start = 0;
	}
#ifdef X11
	//reset color when scroll is finished
	new_fg(p + strlen(p), sd->resetcolor);
#endif
}

void free_scroll(struct text_object *obj)
{
	struct scroll_data *sd = obj->data.opaque;

	if (!sd)
		return;

	if (sd->text)
		free(sd->text);
	if (obj->sub) {
		free_text_objects(obj->sub, 1);
		free(obj->sub);
		obj->sub = NULL;
	}
	free(obj->data.opaque);
	obj->data.opaque = NULL;
}
