#!perl
use strict;
use lib qw(Apache2);
use warnings FATAL => 'all';
use Apache::TestRunPerl();

Apache::TestRunPerl->new->run(@ARGV);
