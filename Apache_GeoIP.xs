#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "libGeoIP.h"
#include "libGeoIP_internal.h"
#include "libGeoIPCity.h"

#ifdef __cplusplus
}
#endif

MODULE = Apache::GeoIP	PACKAGE = Apache::GeoIP

PROTOTYPES: DISABLE

GeoIP *
new_gip(CLASS,flags = 0)
	char * CLASS
	int flags
    CODE:
	RETVAL = GeoIP_new(flags);
    OUTPUT:
	RETVAL

GeoIP *
open(CLASS,filename,flags = 0)
	char * CLASS
	char * filename
	int flags
    CODE:
	RETVAL = GeoIP_open(filename,flags);
    OUTPUT:
	RETVAL

int
id_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    CODE:
	RETVAL = GeoIP_id_by_addr(gi,addr);
    OUTPUT:
	RETVAL

int
id_by_name(gi, name)
	GeoIP *gi
	char * name
    CODE:
	RETVAL = GeoIP_id_by_name(gi,name);
    OUTPUT:
	RETVAL

char *
_country_code_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    CODE:
	RETVAL = (char *)GeoIP_country_code_by_addr(gi,addr);
    OUTPUT:
	RETVAL

char *
_country_code_by_name(gi, name)
	GeoIP *gi
	char * name
    CODE:
	RETVAL = (char *)GeoIP_country_code_by_name(gi,name);
    OUTPUT:
	RETVAL

char *
_country_code3_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    CODE:
	RETVAL = (char *)GeoIP_country_code3_by_addr(gi,addr);
    OUTPUT:
	RETVAL

char *
_country_code3_by_name(gi, name)
	GeoIP *gi
	char * name
    CODE:
	RETVAL = (char *)GeoIP_country_code3_by_name(gi,name);
    OUTPUT:
	RETVAL

char *
_country_name_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    CODE:
	RETVAL = (char *)GeoIP_country_name_by_addr(gi,addr);
    OUTPUT:
	RETVAL

char *
_country_name_by_name(gi, name)
	GeoIP *gi
	char * name
    CODE:
	RETVAL = (char *)GeoIP_country_name_by_name(gi,name);
    OUTPUT:
	RETVAL

char *
_org_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    CODE:
        RETVAL = (char *)GeoIP_org_by_addr(gi,addr);
    OUTPUT:
	RETVAL

char *
_org_by_name(gi, name)
	GeoIP *gi
	char * name
    CODE:
        RETVAL = (char *)GeoIP_org_by_name(gi,name);
    OUTPUT:
	RETVAL

void
_region_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    PREINIT:
	GeoIPRegion * gir;
    PPCODE:
	gir = GeoIP_region_by_addr(gi,addr);
	EXTEND(SP,2);
	PUSHs( sv_2mortal( newSVpv(gir->country_code, 2) ) );
	PUSHs( sv_2mortal( newSVpv(gir->region, 2) ) );
	GeoIPRegion_delete(gir);

void
_region_by_name(gi, name)
	GeoIP *gi
	char * name
    PREINIT:
	GeoIPRegion * gir;
    PPCODE:
	gir = GeoIP_region_by_name(gi,name);
	EXTEND(SP,2);
	PUSHs( sv_2mortal( newSVpv(gir->country_code, 2) ) );
	PUSHs( sv_2mortal( newSVpv(gir->region, 2) ) );
	GeoIPRegion_delete(gir);

GeoIPRecord *
_record_by_addr(gi, addr)
	GeoIP *gi
	char * addr
    PREINIT:
	char * CLASS = "Apache::GeoIP::Record";
    CODE:
	RETVAL = GeoIP_record_by_addr(gi,addr);
    OUTPUT:
	RETVAL

GeoIPRecord *
_record_by_name(gi, addr)
	GeoIP *gi
	char * addr
    PREINIT:
	char * CLASS = "Apache::GeoIP::Record";
    CODE:
	RETVAL = GeoIP_record_by_name(gi,addr);
    OUTPUT:
	RETVAL

void
DESTROY(gi)
	GeoIP *gi
    CODE:
	GeoIP_delete(gi);

MODULE = Apache::GeoIP        PACKAGE = Apache::GeoIP::Record

char *
_country_code(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->country_code;
    OUTPUT:
	RETVAL

char *
_country_code3(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->country_code3;
    OUTPUT:
	RETVAL

char *
_country_name(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->country_name;
    OUTPUT:
	RETVAL

char *
_region(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->region;
    OUTPUT:
	RETVAL

char *
_city(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->city;
    OUTPUT:
	RETVAL

char *
_postal_code(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->postal_code;
    OUTPUT:
	RETVAL

double
_latitude(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->latitude;
    OUTPUT:
	RETVAL

double
_longitude(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->longitude;
    OUTPUT:
	RETVAL

int
dma_code(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->dma_code;
    OUTPUT:
	RETVAL

int
area_code(gir)
	GeoIPRecord *gir
    CODE:
	RETVAL = gir->area_code;
    OUTPUT:
	RETVAL

void
DESTROY(gir)
	GeoIPRecord *gir
    CODE:
	GeoIPRecord_delete(gir);