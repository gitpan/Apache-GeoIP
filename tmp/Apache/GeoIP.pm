package Apache::GeoIP;

use strict;
use vars qw($VERSION);
require DynaLoader;

@Apache::GeoIP::ISA = qw(DynaLoader);

$VERSION = '0.26';

__PACKAGE__->bootstrap($VERSION);

1;

__END__

=head1 NAME

Apache::GeoIP - Look up country by IP Address

=head1 SEE ALSO

L<Apache::Geo::IP> and L<Apache::Geo::Mirror>.

=head1 AUTHOR

The look-up code for associating a country with an IP address 
is based on the GeoIP library and the Geo::IP Perl module, and is 
Copyright (c) 2002, T.J. Mather, tjmather@tjmather.com, New York, NY, 
USA. See http://www.maxmind.com/ for details. The mod_perl interface is 
Copyright (c) 2002, Randy Kobes <randy@theoryx5.uwinnipeg.ca>.

All rights reserved.  This package is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.

=cut
