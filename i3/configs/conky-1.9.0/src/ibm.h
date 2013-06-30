/* -*- mode: c; c-basic-offset: 4; tab-width: 4; indent-tabs-mode: t -*- */

#ifndef _IBM_H
#define _IBM_H

#include <sys/types.h>

int get_ibm_acpi_fan(struct text_object *, char *, int);
int get_ibm_acpi_temps(void);
void get_ibm_acpi_volume(struct text_object *, char *, int);
void get_ibm_acpi_brightness(struct text_object *, char *, int);

void parse_ibm_temps_arg(struct text_object *, const char *);
void print_ibm_temps(struct text_object *, char *, int);
#endif /* _IBM_H */
