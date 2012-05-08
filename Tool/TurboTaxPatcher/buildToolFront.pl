#!/usr/bin/perl -w 
# requires PAR::Packer run the following command (only once per machine) to install PAR::Packer:
#  sudo perl -MCPAN -e 'install PAR::Packer'
#compile instructions:
#pp -o createPrime.out createPrime.pl

use strict;
use warnings 'all';
use IO::File;
use File::Temp qw/ tempfile tempdir /;
use File::Basename;
use Getopt::Long;                                                               

#my $uutempdir = tempdir( CLEANUP => 0 );
my $uutempdir = tempdir( "com.intuit.TurboTaxXXXXXXXXXXXXXXXX", TMPDIR => 1, CLEANUP => 0);
#print "Temp dir = $uutempdir\n" if $verbose;

#cat /Users/jelwell/dev/es/Src/TurboTaxPatcher/build/Release/TurboTaxPatcher.zip | uuencode -o /Users/jelwell/dev/es/Src/TurboTaxPatcher/build/Release/TurboTaxPatcher.uu

my $uuencode="