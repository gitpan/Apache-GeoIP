package TestApache::mirror;
use Apache::Geo::Mirror;
use strict;
use warnings FATAL => 'all';

use Apache::Constants qw(OK);

sub handler {
  my $r = Apache::Geo::Mirror->new(shift);
  $r->content_type('text/plain');
  $r->send_http_header;
  my $ip = $r->args;
  my $mirror;
  if ($ip =~ /^\d/) {
    $mirror = $r->find_mirror_by_addr($ip);
  }
  else {
    $mirror = $r->find_mirror_by_country($ip);

  }
  
  $r->print($mirror);
  
  OK;
}
1;

__END__
