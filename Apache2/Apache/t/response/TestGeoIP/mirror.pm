package TestGeoIP::mirror;
use Apache::Geo::Mirror;
use strict;
use warnings FATAL => 'all';

use Apache::Const -compile => 'OK';
use Apache::RequestIO ();   # for $r->print
use Apache::RequestRec ();  # for $r->content_type

sub handler {
  my $r = Apache::Geo::Mirror->new(shift);
  $r->content_type('text/plain');
  my $ip = $r->args;
  my $mirror;
  if ($ip =~ /^\d/) {
    $mirror = $r->find_mirror_by_addr($ip);
  }
  else {
    $mirror = $r->find_mirror_by_country($ip);

  }
  
  $r->print($mirror);
  
  Apache::OK;
}
1;

__DATA__
<NoAutoConfig>
<Location /cpan>
  SetHandler modperl
  PerlResponseHandler TestGeoIP::mirror
  PerlSetVar GeoIPMirror "@ServerRoot@/conf/cpan_mirror.txt"
  PerlSetVar GeoIPFlag MEMORY_CACHE
</Location>

<Location /apache>
  SetHandler modperl
  PerlResponseHandler TestGeoIP::mirror
  PerlSetvar GeoIPMirror "@ServerRoot@/conf/apache_mirror.txt"
  PerlSetVar GeoIPDefault us
</Location>
</NoAutoConfig>
