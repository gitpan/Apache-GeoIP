use strict;
use ExtUtils::MakeMaker;
use Config;
use Cwd;
use File::Copy;
use File::Path;
use File::Find;
use File::Basename;
require 5.006001;

use constant WIN32 => ($^O =~ /Win32/i);

my (%config, $ans, $GEOIP_DBFILE, $GEOIP_DBCITYFILE, @src_files);
my $db_file = 'GeoIP.dat';
my $city_file = 'GeoIPCity.dat';
my $db_dir = WIN32 ? $ENV{ProgramFiles} . '/GeoIP' : '/usr/local/share/GeoIP';
$db_dir =~ s!\\!/!g;

if (-d $db_dir) {
  if (-e "$db_dir/$db_file") {
    $ans = prompt("Should I use the GeoIP.dat under $db_dir?", 'yes');
    if ($ans =~ /^y/i) {
      $GEOIP_DBFILE = $db_dir . '/' . $db_file;
    }
    else {
      place_db();
    }
  }
  else {
    copy($db_file, $db_dir) or die "Cannot copy $db_file to $db_dir: $!";
    $GEOIP_DBFILE = $db_dir . '/' . $db_file;
  }
}
else {
  place_db();
}

if (-d $db_dir) {
  if (-e "$db_dir/$city_file") {
    $ans = prompt("Should I use the GeoIPCity.dat under $db_dir?", 'yes');
    if ($ans =~ /^y/i) {
      $GEOIP_DBCITYFILE = $db_dir . '/' . $city_file;
    }
  }
}

unless ($GEOIP_DBCITYFILE) {
  $ans = prompt("Do you have the GeoIPCity.dat database?", 'no');
  if ($ans =~ /^y/i) {
    my $dir = prompt("In which directory is it located?", $db_dir);
    $dir =~ s!\\!/!g;
    $dir =~ s!/$!!;
    if (-e "$dir/$city_file") {
      $GEOIP_DBCITYFILE = $dir . '/' . $city_file;
    }
    else {
      warn("Cannot find $city_file under $dir -- ignoring ...");
    }
  }
}

sub place_db {
  my $wanted = WIN32 ? $db_dir :
    prompt('Where should I install GeoIP.dat?', $db_dir);
  $wanted =~ s!\\!/!g;
  $wanted =~ s!/$!!;
  if (-d $wanted) {
    $db_dir = $wanted;
    if (-e "$wanted/$db_file") {
      $ans = prompt("Overwrite $wanted/$db_file?", 'no');
      if ($ans =~ /^y/i) {
	copy($db_file, $wanted) or die "Cannot copy $db_file to $wanted: $!";
      }
      $GEOIP_DBFILE = $wanted . '/' . $db_file;
    }
    else {
      copy($db_file, $wanted) or die "Cannot copy $db_file to $wanted: $!";
      $GEOIP_DBFILE = $wanted . '/' . $db_file;
    }
  }
  elsif (-e $wanted) {
    die qq{A file by the name of "$wanted" exists};
  }
  else {
    $ans = prompt(qq[Create "$wanted"?], 'yes');
    if ($ans =~ /^y/i) {
      mkpath($wanted, 1, 0755) or die "mkpath $wanted failed: $!";
      copy($db_file, $wanted) or die "Cannot copy $db_file to $wanted: $!";
      $GEOIP_DBFILE = $wanted . '/' . $db_file;
      $db_dir = $wanted;
    }
    else {
      die "Need $db_file installed somewhere to work";
    }
  }
}


my $objs = 'libGeoIP.o libGeoIPCity.o GeoIP.o';

my $to_edit = { 'Mirror.pm' => 
		{'my $GEOIP_DBFILE;' => 
		 qq{my \$GEOIP_DBFILE = "$GEOIP_DBFILE";}},
		'IP.pm' => {'my $GEOIP_DBFILE;' => 
			    qq{my \$GEOIP_DBFILE = "$GEOIP_DBFILE";}},
	      };

if (my $GEOIP_DBCITYFILE) {
  $to_edit->{'Record.pm'}->{'my $GEOIP_DBCITYFILE;'} =
    qq{my \$GEOIP_DBCITYFILE = "$GEOIP_DBCITYFILE";};
}

my ($libdir, $files_to_clean) = mp_copy($to_edit);
my $mpv = ($libdir eq 'Apache') ? 1.26 : 1.99;
push @$files_to_clean, 't/TEST';

$config{LIBS} = WIN32 ? ' -lzlib' : ' -lz';
$config{DEFINE} = qq{ -DGEOIPDATADIR=\\"$db_dir\\"} unless WIN32;

WriteMakefile(
	      NAME           => 'Apache::GeoIP',
	      VERSION_FROM   => "$libdir/GeoIP.pm",
              PREREQ_PM      => { mod_perl => $mpv },
	      ($] >= 5.005 ?   
	       (ABSTRACT_FROM => "$libdir/GeoIP.pm",
		AUTHOR     => 'Randy Kobes <randy@theoryx5.uwinnipeg.ca>') 
	       : ()),
	      clean          => { FILES => "@$files_to_clean"},
              OBJECT         => $objs,
	      dist           => {
				 SUFFIX   => 'gz',
				 COMPRESS => 'gzip -9f',
				},
	      %config,
	     );

# use Apache::Test to test things, but if not available,
# print out a message to that effect for 'make test'

sub MY::test {
  eval {require Apache::TestMM; import Apache::TestMM qw(test clean)};
  unless ($@) {
    Apache::TestMM::generate_script('t/TEST');
    return Apache::TestMM->test;
  }
  
  return <<'EOF';
test::
	@echo This test suite requires Apache::Test,
	@echo available from the mod_perl 2 sources
	@echo or from the httpd-test distribution.
EOF

}

#######################################################################
# The following routine assumes the existence of two subdirectories:
#   Apache: for mod_perl-1 things
#   Apache2/Apache: for mod_perl-2 things
# which_modperl() is called to determine which of the two
# directories to use, depending on availability of
# mod_perl and/or user input. The files under the
# chosen directory are then copied under the lib/ directory
# for subsequent installation. If there is a t/ directory
# under either Apache or Apache2/Apache, the files under
# this directory are copied beneath the top-level t/.
# 
# An optional argument may be specified which is a
# hash reference containing a list of files that require
# editing before being copied. The form of this is
#
#   $to_edit =  { file1 => { sub1 => 'pat1', sub2 => 'pat2'},
#                 file2 => { sub3 => 'pat3', sub4 => 'pat4'},
#               };
#
# which will replace "sub1" by "pat1" in file1, etc.
# Simple filenames alone may be specified, except when
# an ambiguity exists, in which case a full path (relative
# to the top-level directory) should be given.
#
# The routine returns a list containing two items - which
# of the directories (Apache or Apache2) is used, and also
# an array reference of files copied to the lib/ or t/ directories
#
########################################################################

sub mp_copy {
  my $to_edit = shift;
  
  my $apache_dir = which_modperl();
  @src_files = ();
  my @dest_files = ();
  finddepth(\&wanted, $apache_dir);

  foreach my $src (@src_files) {
    my $dir = dirname($src);
    my $dest_dir;
    if ($dir =~ m!/t/?(.*)!) {
      $dest_dir = "t/$1";
    }
    else {
      $dest_dir = 'lib/' . $dir;
    }
    unless (-d $dest_dir) {
      mkpath($dest_dir, 1, 0755) or die "mkpath $dest_dir failed: $!";
    }
    my $base = basename($src);
    my $dest_file = $dest_dir . '/' . $base;
    push @dest_files, $dest_file;
    my $key = $src;
    if ( $to_edit and ($to_edit->{$key} or $to_edit->{$base})) {
      my $subs = $to_edit->{$key} || $to_edit->{$base};
      open(OLD, $src) or die "Cannot open $src: $!";
      open(NEW, ">$dest_file") or die "Cannot open $dest_file: $!";
      while (<OLD>) {
	foreach my $pattern (keys %{$subs}) {
	  s/\Q$pattern\E/$subs->{$pattern}/g;
	}
	print NEW $_;
      }
      close OLD;
      close NEW;
    }
    else {
      copy($src, $dest_file) or die "Cannot copy $src to $dest_file: $!";
    }
  }
  return ($apache_dir, \@dest_files);
}

sub wanted {
  my $name = $File::Find::name;
  not (-d $_ or $name =~ m!CVS!) and push @src_files, $name; 
}

sub which_modperl {
  my ($mp1, $mp2);
  eval {require Apache2;};
  $mp2 = 1 unless $@;
  eval {require Apache::src;};
  $mp1 = 1 unless $@;
  
  die "Please install either mod_perl (version 1 or 2)"
    unless ($mp1 or $mp2);
  my $ans;
  if ($mp2) {
    $ans = prompt('Install mod_perl-2 version?', 'yes');
    if ($ans =~ /^y/i) {
      return 'Apache2/Apache';
    }
    else {
      if ($mp1) {
	$ans = prompt('Install mod_perl-1 version?', 'yes');
	if ($ans =~ /^y/i) {
	  return 'Apache';
	}
	else {
	  die "Need to install one version or the other";
	}
      }
      else {
	die "Only mod_perl version 2 detected";
      }
    }
  }
  else {
    return 'Apache';
  }
  
}
