use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 20; # plan one test.

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

while (<DATA>) {
  chomp;
  my ($ipaddr, $exp_country) = split("\t");
 
 my $received = GET_BODY "/name?$ipaddr";
my $expected = $exp_country;
  
ok t_cmp(
        $expected,
        $received,
        "testing name with $ipaddr",
        );

}

__DATA__
203.174.65.12	JP
212.208.74.140	FR
200.219.192.106	BR
134.102.101.18	DE
193.75.148.28	BE
134.102.101.18	DE
147.251.48.1	CZ
194.244.83.2	IT
203.15.106.23	AU
196.31.1.1	ZA
yahoo.com	US
www.bundesregierung.de	DE
www.thaigov.go.th	TH
www.gov.ru	RU
www.parliament.ge	GE
www.cpv.org.vn	VN
alfa.nic.in	IN
io.uwinnipeg.ca	CA
www.maxmind.com	US
q.r.nosuchdomain	
