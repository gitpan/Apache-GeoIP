package TestApache::mirror;
use Apache::Geo::Mirror;
use strict;
use warnings FATAL => 'all';

use Apache::Const -compile => 'OK';

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

__END__
