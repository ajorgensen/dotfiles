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
#include "colours.h"
#ifdef X11
#include "fonts.h"
#endif /* X11 */
#include "logging.h"
#include "specials.h"
#include <math.h>
#include <ctype.h>

/* maximum number of special things, e.g. fonts, offsets, aligns, etc. */
int max_specials = MAX_SPECIALS_DEFAULT;

/* create specials array on heap instead of stack with introduction of
 * max_specials */
struct special_t *specials = NULL;

int special_count;

int default_bar_width = 0, default_bar_height = 6;
#ifdef X11
int default_graph_width = 0, default_graph_height = 25;
#endif /* X11 */
int default_gauge_width = 40, default_gauge_height = 25;

/*
 * Special data typedefs
 */

struct bar {
	int width, height;
};

struct gauge {
	int width, height;
};

struct graph {
	int width, height;
	unsigned int first_colour, last_colour;
	unsigned int scale, showaslog;
	char tempgrad, dotgraph;
};

struct stippled_hr {
	int height, arg;
};

struct tab {
	int width, arg;
};

/*
 * Scanning arguments to various special text objects
 */

const char *scan_gauge(struct text_object *obj, const char *args)
{
	struct gauge *g;

	g = malloc(sizeof(struct gauge));
	memset(g, 0, sizeof(struct gauge));

	/*width and height*/
	g->width = default_gauge_width;
	g->height = default_gauge_height;

	/* gauge's argument is either height or height,width */
	if (args) {
		int n = 0;

		if (sscanf(args, "%d,%d %n", &g->height, &g->width, &n) <= 1) {
			if (sscanf(args, "%d %n", &g->height, &n) == 2) {
				g->width = g->height; /*square gauge*/
			}
		}
		args += n;
	}

	obj->special_data = g;
	return args;
}

const char *scan_bar(struct text_object *obj, const char *args)
{
	struct bar *b;

	b = malloc(sizeof(struct bar));
	memset(b, 0, sizeof(struct bar));

	/* zero width means all space that is available */
	b->width = default_bar_width;
	b->height = default_bar_height;
	/* bar's argument is either height or height,width */
	if (args) {
		int n = 0;

		if (sscanf(args, "%d,%d %n", &b->height, &b->width, &n) <= 1) {
			sscanf(args, "%d %n", &b->height, &n);
		}
		args += n;
	}

	obj->special_data = b;
	return args;
}

#ifdef X11
char *scan_font(const char *args)
{
	if (args && *args) {
		return strndup(args, DEFAULT_TEXT_BUFFER_SIZE);
	}

	return NULL;
}

char *scan_graph(struct text_object *obj, const char *args, int defscale)
{
	struct graph *g;
	char buf[1024];
	memset(buf, 0, 1024);

	g = malloc(sizeof(struct graph));
	memset(g, 0, sizeof(struct graph));
	obj->special_data = g;

	/* zero width means all space that is available */
	g->width = default_graph_width;
	g->height = default_graph_height;
	g->first_colour = 0;
	g->last_colour = 0;
	g->scale = defscale;
	g->tempgrad = FALSE;
	g->dotgraph = FALSE;
	g->showaslog = FALSE;
	if (args) {
		if (strstr(args, " "TEMPGRAD) || strncmp(args, TEMPGRAD, strlen(TEMPGRAD)) == 0) {
			g->tempgrad = TRUE;
		}
		if (strstr(args, " "DOTGRAPH) || strncmp(args, DOTGRAPH, strlen(DOTGRAPH)) == 0) {
			g->dotgraph = TRUE;
		}
		if (strstr(args, " "LOGGRAPH) || strncmp(args, LOGGRAPH, strlen(LOGGRAPH)) == 0) {
			g->showaslog = TRUE;
		}
		if (sscanf(args, "%d,%d %x %x %u", &g->height, &g->width, &g->first_colour, &g->last_colour, &g->scale) == 5) {
			return NULL;
		}
		g->scale = defscale;
		if (sscanf(args, "%d,%d %x %x", &g->height, &g->width, &g->first_colour, &g->last_colour) == 4) {
			return NULL;
		}
		if (sscanf(args, "%1023s %d,%d %x %x %u", buf, &g->height, &g->width, &g->first_colour, &g->last_colour, &g->scale) == 6) {
			return strndup(buf, text_buffer_size);
		}
		g->scale = defscale;
		if (sscanf(args, "%1023s %d,%d %x %x", buf, &g->height, &g->width, &g->first_colour, &g->last_colour) == 5) {
			return strndup(buf, text_buffer_size);
		}
		buf[0] = '\0';
		g->height = 25;
		g->width = 0;
		if (sscanf(args, "%x %x %u", &g->first_colour, &g->last_colour, &g->scale) == 3) {
			return NULL;
		}
		g->scale = defscale;
		if (sscanf(args, "%x %x", &g->first_colour, &g->last_colour) == 2) {
			return NULL;
		}
		if (sscanf(args, "%1023s %x %x %u", buf, &g->first_colour, &g->last_colour, &g->scale) == 4) {
			return strndup(buf, text_buffer_size);
		}
		g->scale = defscale;
		if (sscanf(args, "%1023s %x %x", buf, &g->first_colour, &g->last_colour) == 3) {
			return strndup(buf, text_buffer_size);
		}
		buf[0] = '\0';
		g->first_colour = 0;
		g->last_colour = 0;
		if (sscanf(args, "%d,%d %u", &g->height, &g->width, &g->scale) == 3) {
			return NULL;
		}
		g->scale = defscale;
		if (sscanf(args, "%d,%d", &g->height, &g->width) == 2) {
			return NULL;
		}
		if (sscanf(args, "%1023s %d,%d %u", buf, &g->height, &g->width, &g->scale) < 4) {
			g->scale = defscale;
			//TODO: check the return value and throw an error?
			sscanf(args, "%1023s %d,%d", buf, &g->height, &g->width);
		}

		return strndup(buf, text_buffer_size);
	}

	if (buf[0] == '\0') {
		return NULL;
	} else {
		return strndup(buf, text_buffer_size);
	}
}

// scan_graph is a mess and it does not work for execgraph, so i'll just rewrite it for this case
char *scan_execgraph(struct text_object *obj, const char *arg)
{
	struct graph *g;

	g = malloc(sizeof(struct graph));
	memset(g, 0, sizeof(struct graph));
	obj->special_data = g;

	/* zero width means all space that is available */
	g->width = default_graph_width;
	g->height = default_graph_height;
	g->first_colour = 0;
	g->last_colour = 0;
	g->scale = 100;
	g->tempgrad = FALSE;
	g->showaslog = FALSE;

	while(arg && *arg) {
		while(isspace(*arg)) ++arg;

		if(strncmp(arg, TEMPGRAD, strlen(TEMPGRAD)) == 0 && !isalnum(arg[strlen(TEMPGRAD)])) {
			g->tempgrad = TRUE;
			arg += strlen(TEMPGRAD);
			continue;
		}

		if(strncmp(arg, LOGGRAPH, strlen(LOGGRAPH)) == 0 && !isalnum(arg[strlen(LOGGRAPH)])) {
			g->showaslog = TRUE;
			arg += strlen(LOGGRAPH);
			continue;
		}

		return strdup(arg);
	}

	return NULL;
}
#endif /* X11 */

/*
 * Printing various special text objects
 */

static struct special_t *new_special(char *buf, enum special_types t)
{
	if (special_count >= max_specials) {
		CRIT_ERR(NULL, NULL, "too many special things in text");
	}

	buf[0] = SPECIAL_CHAR;
	buf[1] = '\0';
	specials[special_count].type = t;
	return &specials[special_count++];
}

void new_gauge_in_shell(struct text_object *obj, char *p, int p_max_size, int usage)
{
	static const char *gaugevals[] = { "_. ", "\\. ", " | ", " ./", " ._" };
	(void)obj;

	snprintf(p, p_max_size, "%s", gaugevals[round_to_int((double)usage * 4 / 255)]);
}

#ifdef X11
void new_gauge_in_x11(struct text_object *obj, char *buf, int usage)
{
	struct special_t *s = 0;
	struct gauge *g = obj->special_data;

	if ((output_methods & TO_X) == 0)
		return;

	if (!g)
		return;

	s = new_special(buf, GAUGE);

	s->arg = usage;
	s->width = g->width;
	s->height = g->height;
}
#endif /* X11 */

void new_gauge(struct text_object *obj, char *p, int p_max_size, int usage)
{
	if (!p_max_size)
		return;

	usage = (usage > 255) ? 255 : ((usage < 0) ? 0 : usage);

#ifdef X11
	if (output_methods & TO_X)
		new_gauge_in_x11(obj, p, usage);
	else
#endif /* X11 */
		new_gauge_in_shell(obj, p, p_max_size, usage);
}

#ifdef X11
void new_font(char *buf, char *args)
{
	if ((output_methods & TO_X) == 0)
		return;

	if (args) {
		struct special_t *s = new_special(buf, FONT);

		if (s->font_added > font_count || !s->font_added || (strncmp(args, fonts[s->font_added].name, DEFAULT_TEXT_BUFFER_SIZE) != EQUAL) ) {
			int tmp = selected_font;

			selected_font = s->font_added = add_font(args);
			selected_font = tmp;
		}
	} else {
		struct special_t *s = new_special(buf, FONT);
		int tmp = selected_font;

		selected_font = s->font_added = 0;
		selected_font = tmp;
	}
}

static void graph_append(struct special_t *graph, double f, char showaslog)
{
	int i;

	/* do nothing if we don't even have a graph yet */
	if (!graph->graph) return;

	if (showaslog) {
#ifdef MATH
		f = log10(f + 1);
#endif
	}

	if (!graph->scaled && f > graph->graph_scale) {
		f = graph->graph_scale;
	}

	/* shift all the data by 1 */
	for (i = graph->graph_allocated - 1; i > 0; i--) {
		graph->graph[i] = graph->graph[i - 1];
		if (graph->scaled && graph->graph[i - 1] > graph->graph_scale) {
			/* check if we need to update the scale */
			graph->graph_scale = graph->graph[i - 1];
		}
	}
	graph->graph[0] = f;	/* add new data */
	if (graph->scaled && graph->graph[0] > graph->graph_scale) {
		/* check if we need to update the scale */
		graph->graph_scale = graph->graph[0];
	}
}

void new_graph(struct text_object *obj, char *buf, int buf_max_size, double val)
{
	struct special_t *s = 0;
	struct graph *g = obj->special_data;

	if ((output_methods & TO_X) == 0)
		return;

	if (!g || !buf_max_size)
		return;

	s = new_special(buf, GRAPH);

	s->width = g->width;
	if (s->width) s->graph_width = s->width;

	if (s->graph_width != s->graph_allocated) {
		char *graph = realloc(s->graph, s->graph_width * sizeof(double));
		DBGP("reallocing graph from %d to %d", s->graph_allocated, s->graph_width);
		if (!s->graph) {
			/* initialize */
			memset(graph, 0, s->graph_width * sizeof(double));
			s->graph_scale = 100;
		} else {
			if (s->graph_width > s->graph_allocated) {
				/* initialize the new region */
				memset(graph + (s->graph_allocated * sizeof(double)), 0,
						(s->graph_width - s->graph_allocated) *
						sizeof(double));
			}
		}
		s->graph = graph;
		s->graph_allocated = s->graph_width;
	}
	s->height = g->height;
	s->first_colour = adjust_colours(g->first_colour);
	s->last_colour = adjust_colours(g->last_colour);
	if (g->scale != 0) {
		s->scaled = 0;
		s->graph_scale = g->scale;
		s->show_scale = 0;
	} else {
		s->scaled = 1;
		s->graph_scale = 1;
		s->show_scale = 1;
	}
	s->tempgrad = g->tempgrad;
	s->dotgraph = g->dotgraph;
#ifdef MATH
	if (g->showaslog) {
		s->graph_scale = log10(s->graph_scale + 1);
	}
#endif
	graph_append(s, val, g->showaslog);
}

void new_hr(char *buf, int a)
{
	if ((output_methods & TO_X) == 0)
		return;

	new_special(buf, HORIZONTAL_LINE)->height = a;
}

void scan_stippled_hr(struct text_object *obj, const char *arg)
{
	struct stippled_hr *sh;

	sh = malloc(sizeof(struct stippled_hr));
	memset(sh, 0, sizeof(struct stippled_hr));

	sh->arg = get_stippled_borders();
	sh->height = 1;

	if (arg) {
		if (sscanf(arg, "%d %d", &sh->arg, &sh->height) != 2) {
			sscanf(arg, "%d", &sh->height);
		}
	}
	if (sh->arg <= 0) {
		sh->arg = 1;
	}
	obj->special_data = sh;
}

void new_stippled_hr(struct text_object *obj, char *buf)
{
	struct special_t *s = 0;
	struct stippled_hr *sh = obj->special_data;

	if ((output_methods & TO_X) == 0)
		return;

	if (!sh)
		return;

	s = new_special(buf, STIPPLED_HR);

	s->height = sh->height;
	s->arg = sh->arg;
}
#endif /* X11 */

void new_fg(char *buf, long c)
{
#ifdef X11
	if (output_methods & TO_X)
		new_special(buf, FG)->arg = c;
#endif /* X11 */
#ifdef NCURSES
	if (output_methods & TO_NCURSES)
		new_special(buf, FG)->arg = c;
#endif /* NCURSES */
	UNUSED(buf);
	UNUSED(c);
}

#ifdef X11
void new_bg(char *buf, long c)
{
	if ((output_methods & TO_X) == 0)
		return;

	new_special(buf, BG)->arg = c;
}
#endif /* X11 */

static void new_bar_in_shell(struct text_object *obj, char* buffer, int buf_max_size, double usage)
{
	struct bar *b = obj->special_data;
	int width, i, scaledusage;

	if (!b)
		return;

	width = b->width;
	if (!width)
		width = DEFAULT_BAR_WIDTH_NO_X;

	if (width > buf_max_size)
		width = buf_max_size;

	scaledusage = round_to_int( usage * width / 255);

	for (i = 0; i < scaledusage; i++)
		buffer[i] = '#';

	for (; i < width; i++)
		buffer[i] = '_';

	buffer[i] = 0;
}

#ifdef X11
static void new_bar_in_x11(struct text_object *obj, char *buf, int usage)
{
	struct special_t *s = 0;
	struct bar *b = obj->special_data;

	s = new_special(buf, BAR);

	s->arg = usage;
	s->width = b ?  b->width : default_bar_width;
	s->height = b ? b->height : default_bar_height;
}
#endif /* X11 */

/* usage is in range [0,255] */
void new_bar(struct text_object *obj, char *p, int p_max_size, int usage)
{
	if (!p_max_size)
		return;

	usage = (usage > 255) ? 255 : ((usage < 0) ? 0 : usage);

#ifdef X11
	if ((output_methods & TO_X))
		new_bar_in_x11(obj, p, usage);
	else
#endif /* X11 */
		new_bar_in_shell(obj, p, p_max_size, usage);
}

void new_outline(char *buf, long c)
{
	new_special(buf, OUTLINE)->arg = c;
}

void new_offset(char *buf, long c)
{
	new_special(buf, OFFSET)->arg = c;
}

void new_voffset(char *buf, long c)
{
	new_special(buf, VOFFSET)->arg = c;
}

void new_alignr(char *buf, long c)
{
	new_special(buf, ALIGNR)->arg = c;
}

// A postive offset pushes the text further left
void new_alignc(char *buf, long c)
{
	new_special(buf, ALIGNC)->arg = c;
}

void new_goto(char *buf, long c)
{
	new_special(buf, GOTO)->arg = c;
}

void scan_tab(struct text_object *obj, const char *arg)
{
	struct tab *t;

	t = malloc(sizeof(struct tab));
	memset(t, 0, sizeof(struct tab));

	t->width = 10;
	t->arg = 0;

	if (arg) {
		if (sscanf(arg, "%d %d", &t->width, &t->arg) != 2) {
			sscanf(arg, "%d", &t->arg);
		}
	}
	if (t->width <= 0) {
		t->width = 1;
	}
	obj->special_data = t;
}

void new_tab(struct text_object *obj, char *buf)
{
	struct special_t *s = 0;
	struct tab *t = obj->special_data;

	if (!t)
		return;

	s = new_special(buf, TAB);
	s->width = t->width;
	s->arg = t->arg;
}
