#!perl
use strict;
use warnings FATAL => 'all';
use Apache::TestRunPerl();

package MyTest;
our @ISA = qw(Apache::TestRunPerl);
sub pre_configure {
  my $self = shift;
}

MyTest->new->run(@ARGV);
