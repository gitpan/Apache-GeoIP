use strict;
use warnings FATAL => 'all';

use Apache::Test;
use Apache::TestUtil;
use Apache::TestRequest 'GET_BODY';

plan tests => 6; # plan one test.

my $config   = Apache::Test::config();
my $hostport = Apache::TestRequest::hostport($config) || '';
t_debug("connecting to $hostport");

my ($received, $expected);
$received = GET_BODY "/cpan?pk";
$expected = 'http://cpan.in.freeos.com';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );

$received = GET_BODY "/cpan?62.60.128.1";
$expected = 'ftp://ftp.isu.net.sa/pub/CPAN/';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );


$received = GET_BODY "/cpan?210.23.107.55";
$expected = 'http://www.adzu.edu.ph/CPAN';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );

$received = GET_BODY "/apache?pk";
$expected = 'http://apache.bogus.pk/apache/bogus';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );

$received = GET_BODY "/apache?62.60.128.1";
$expected = 'ftp://apache.bogus.sa/pub/apache';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );

$received = GET_BODY "/apache?210.23.107.55";
$expected = 'ftp://apache.bogus.ph/apache';
ok t_cmp(
        $expected,
        $received,
        "testing mirror",
        );

