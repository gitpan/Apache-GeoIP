/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GeoIP.h
 *
 * Copyright (C) 2002 MaxMind.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef GEOIP_H
#define GEOIP_H

#ifdef __cplusplus
extern "C" {
#endif

#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include <sys/types.h> /* for fstat */
#include <sys/stat.h>	/* for fstat */

#define RECORD_LENGTH 3

typedef struct GeoIPTag {
  FILE *GeoIPDatabase;
  char *file_path;
	unsigned char *cache;
	unsigned int *databaseSegments;
	char databaseType;
	time_t mtime;
	int flags;
} GeoIP;

typedef struct GeoIPRegionTag {
	char country_code[3];
	char *region;
} GeoIPRegion;

typedef enum {
	GEOIP_STANDARD = 0,
	GEOIP_MEMORY_CACHE = 1,
	GEOIP_CHECK_CACHE = 2,
} GeoIPOptions;

typedef enum {
	GEOIP_COUNTRY_EDITION = 106,
	GEOIP_REGION_EDITION  = 112,
	GEOIP_CITY_EDITION    = 111,
} GeoIPDBTypes;

extern const char *GeoIPDBFileName;

extern const char GeoIP_country_code[247][3];
extern const char GeoIP_country_code3[247][4];
extern const char * GeoIP_country_name[247];

GeoIP* GeoIP_new(int flags);
GeoIP* GeoIP_open(const char * filename, int flags);
void GeoIP_delete(GeoIP* gi);
const char *GeoIP_country_code_by_addr (GeoIP* gi, const char *addr);
const char *GeoIP_country_code_by_name (GeoIP* gi, const char *host);
const char *GeoIP_country_code3_by_addr (GeoIP* gi, const char *addr);
const char *GeoIP_country_code3_by_name (GeoIP* gi, const char *host);
const char *GeoIP_country_name_by_addr (GeoIP* gi, const char *addr);
const char *GeoIP_country_name_by_name (GeoIP* gi, const char *host);
int GeoIP_country_id_by_addr (GeoIP* gi, const char *addr);
int GeoIP_country_id_by_name (GeoIP* gi, const char *host);

GeoIPRegion * GeoIP_region_by_addr (GeoIP* gi, const char *addr);
GeoIPRegion * GeoIP_region_by_name (GeoIP* gi, const char *host);
void GeoIPRegion_delete (GeoIPRegion *gir);

char *GeoIP_database_info (GeoIP* gi);
unsigned char GeoIP_database_edition (GeoIP* gi);

int _seek_country (GeoIP *gi, unsigned long ipnum);
unsigned long _addr_to_num (const char *addr);
unsigned long _h_addr_to_num (unsigned char *addr);

#ifdef BSD
#define memcpy(dest, src, n) bcopy(src, dest, n)
#endif

#ifdef __cplusplus
}
#endif

#endif /* GEOIP_H */
