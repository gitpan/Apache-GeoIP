package TestApache::ip;
use Apache::Geo::IP;
use strict;
use warnings FATAL => 'all';

use Apache::Const -compile => 'OK';

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

