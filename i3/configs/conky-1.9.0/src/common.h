/* -*- mode: c; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: t -*- 
 * vim: ts=4 sw=4 noet ai cindent syntax=c
 */

#ifndef _COMMON_H
#define _COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include "text_object.h"

void add_update_callback(int (*func)(void));
void free_update_callbacks(void);
void start_update_threading(void);


void strfold(char *start, int count);
int check_mount(char *s);
void prepare_update(void);
int update_uptime(void);
int update_meminfo(void);
int update_net_stats(void);
int update_cpu_usage(void);
int update_total_processes(void);
int update_uname(void);
int update_threads(void);
int update_running_processes(void);
void update_stuff(void);
char get_freq(char *, size_t, const char *, int, unsigned int);
void print_voltage_mv(struct text_object *, char *, int);
void print_voltage_v(struct text_object *, char *, int);
int update_load_average(void);
int update_top(void);
void free_all_processes(void);
struct process *get_first_process(void);
void get_cpu_count(void);
double get_time(void);

/* Converts '~/...' paths to '/home/blah/...' assumes that 'dest' is at least
 * DEFAULT_TEXT_BUFFER_SIZE.  It's similar to variable_substitute, except only
 * cheques for $HOME and ~/ in path */
void to_real_path(char *dest, const char *source);
FILE *open_file(const char *file, int *reported);
int open_fifo(const char *file, int *reported);
void variable_substitute(const char *s, char *dest, unsigned int n);

void format_seconds(char *buf, unsigned int n, long t);
void format_seconds_short(char *buf, unsigned int n, long t);

#ifdef X11
int update_x11info(void);
#endif

int round_to_int_temp(float);

unsigned int round_to_int(float);

extern int no_buffers;

int open_acpi_temperature(const char *name);
double get_acpi_temperature(int fd);
void get_acpi_ac_adapter(char *p_client_buffer, size_t client_buffer_size, const char *adapter);
void get_acpi_fan(char *, size_t);
void get_battery_stuff(char *buf, unsigned int n, const char *bat, int item);
int get_battery_perct(const char *bat);
int get_battery_perct_bar(const char *bat);
void get_battery_short_status(char *buf, unsigned int n, const char *bat);

void scan_loadavg_arg(struct text_object *, const char *);
void print_loadavg(struct text_object *, char *, int);
#ifdef X11
void scan_loadgraph_arg(struct text_object *, const char *);
void print_loadgraph(struct text_object *, char *, int);
#endif /* X11 */

#endif /* _COMMON_H */
