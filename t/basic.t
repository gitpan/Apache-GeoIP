use strict;
use warnings FATAL => 'all';
use Apache::Test;
use Apache::TestUtil;
eval {require Apache2;};
plan tests => 6;

ok require 5.006001;
ok require mod_perl;
ok require Apache::GeoIP;
ok require Apache::Geo::IP;
ok require Apache::Geo::IP::Record;
ok require Apache::Geo::Mirror;
