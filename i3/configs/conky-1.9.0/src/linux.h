/* -*- mode: c; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: t -*- */

#ifndef _LINUX_H
#define _LINUX_H

#include "common.h"

const char *get_disk_protect_queue(const char *);

char *get_ioscheduler(char *);
int get_laptop_mode(void);

int update_gateway_info(void);
void free_gateway_info(void);
int gateway_exists(void);
void print_gateway_iface(char *, int);
void print_gateway_ip(char *, int);

enum { PB_BATT_STATUS, PB_BATT_PERCENT, PB_BATT_TIME };
void get_powerbook_batt_info(char *, size_t, int);

void parse_i2c_sensor(struct text_object *, const char *);
void parse_hwmon_sensor(struct text_object *, const char *);
void parse_platform_sensor(struct text_object *, const char *);
void print_sysfs_sensor(struct text_object *, char *, int );
void free_sysfs_sensor(struct text_object *);

int get_entropy_avail(unsigned int *);
int get_entropy_poolsize(unsigned int *);

int update_stat(void);

#endif /* _LINUX_H */
