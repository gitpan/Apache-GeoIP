use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 3; # plan one test.

Apache::TestRequest::module('default');

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

my ($received, $expected);
$received = GET_BODY "/TestApache::mirror?pk";
$expected = 'http://cpan.in.freeos.com';
ok t_cmp(
        $expected,
        $received,
        "testing TestApache::mirror",
        );

$received = GET_BODY "/TestApache::mirror?62.60.128.1";
$expected = 'ftp://ftp.isu.net.sa/pub/CPAN/';
ok t_cmp(
        $expected,
        $received,
        "testing TestApache::mirror",
        );

$received = GET_BODY "/TestApache::mirror?210.23.107.55";
$expected = 'http://www.adzu.edu.ph/CPAN';
ok t_cmp(
        $expected,
        $received,
        "testing TestApache::mirror",
        );

