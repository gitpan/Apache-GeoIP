package TestGeoIP::ip;
use Apache::Geo::IP;
use strict;
use warnings FATAL => 'all';

use Apache::Const -compile => 'OK';
use Apache::RequestIO ();   # for $r->print
use Apache::RequestRec ();  # for $r->content_type

sub handler {
  my $r = Apache::Geo::IP->new(shift);
  $r->content_type('text/plain');
  my $ip = $r->args;
  my $country = uc($r->country_code_by_addr($ip));
  
  $r->print($country);
  
  Apache::OK;
}
1;

__END__

