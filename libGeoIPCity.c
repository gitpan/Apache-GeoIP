/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* GeoIPCity.c
 *
 * Copyright (C) 2002 MaxMind.com
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
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

#include "libGeoIP.h"
#include "libGeoIPCity.h"
#ifndef WIN32
#include <netdb.h>
#else
#include <winsock2.h>
#endif	/* WIN32 */

const int FULL_RECORD_LENGTH = 50;

GeoIPRecord * _get_record(GeoIP* gi, unsigned long ipnum) {
	int record_pointer;
	unsigned char *record_buf = NULL;
	unsigned char *begin_record_buf = NULL;
	GeoIPRecord * record;
	int str_length = 0;
	int j;
        unsigned int seek_country;
	double latitude = 0, longitude = 0;

	seek_country = _seek_country(gi, ipnum);
	if (seek_country == gi->databaseSegments[0])		
		return NULL;

	record = malloc(sizeof(GeoIPRecord));
	memset(record, 0, sizeof(GeoIPRecord));

	record_pointer = seek_country + (2 * gi->record_length - 1) * gi->databaseSegments[0];

	if (gi->cache == NULL) {
		fseek(gi->GeoIPDatabase, record_pointer, SEEK_SET);
		begin_record_buf = record_buf = malloc(sizeof(char) * FULL_RECORD_LENGTH);
		fread(record_buf, sizeof(char), FULL_RECORD_LENGTH, gi->GeoIPDatabase);
	} else {
		record_buf = gi->cache + (long)record_pointer;
	}

	/* get country */
	record->country_code	= (char *) GeoIP_country_code [record_buf[0]];
	record->country_code3 = (char *) GeoIP_country_code3[record_buf[0]];
	record->country_name	= (char *) GeoIP_country_name [record_buf[0]];
	record_buf++;

	/* get region */
	while (record_buf[str_length] != '\0')
		str_length++;
	if (str_length > 0) {
		record->region = malloc(str_length+1);
		strncpy(record->region, record_buf, str_length+1);
	}
	record_buf += str_length + 1;
	str_length = 0;

	/* get city */
	while (record_buf[str_length] != '\0')
		str_length++;
	if (str_length > 0) {
		record->city = malloc(str_length+1);
		strncpy(record->city, record_buf, str_length+1);
	}
	record_buf += (str_length + 1);
	str_length = 0;

	/* get postal code */
	while (record_buf[str_length] != '\0')
		str_length++;
	if (str_length > 0) {
		record->postal_code = malloc(str_length+1);
		strncpy(record->postal_code, record_buf, str_length+1);
	}
	record_buf += (str_length + 1);

	/* get latitude */
	for (j = 0; j < 3; ++j)
		latitude += (record_buf[j] << (j * 8));
	record->latitude = latitude/10000 - 180;
	record_buf += 3;

	/* get longitude */
	for (j = 0; j < 3; ++j)
		longitude += (record_buf[j] << (j * 8));
	record->longitude = longitude/10000 - 180;

	if (gi->cache == NULL)
		free(begin_record_buf);

	return record;
}

GeoIPRecord * GeoIP_record_by_addr (GeoIP* gi, const char *addr) {
	unsigned long ipnum;
	if (addr == NULL) {
		return 0;
	}
	ipnum = _addr_to_num(addr);
	if(ipnum == 0) return 0;
	return _get_record(gi, ipnum);
}

GeoIPRecord * GeoIP_record_by_name (GeoIP* gi, const char *name) {
	unsigned long ipnum;
	struct hostent * host;
	if (name == NULL) {
		return 0;
	}
	ipnum = _addr_to_num(name);
	if (ipnum == 0) {
		host = gethostbyname(name);
		if (host == NULL) {
			return 0;
		}
		ipnum = _h_addr_to_num((unsigned char *) host->h_addr_list[0]);
		if(ipnum == 0) return 0;
	}
	return _get_record(gi, ipnum);
}

void GeoIPRecord_delete (GeoIPRecord *gir) {
	free(gir->region);
	free(gir->city);
	free(gir->postal_code);
	free(gir);
}
