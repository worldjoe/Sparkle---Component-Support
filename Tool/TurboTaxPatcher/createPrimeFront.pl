#!/usr/bin/perl -w 
# requires PAR::Packer run the following command (only once per machine) to install PAR::Packer:
#  sudo perl -MCPAN -e 'install PAR::Packer'
#compile instructions:
#pp -o createPrime.out createPrime.pl

use strict;
use warnings 'all';
use XML::Parser;
use XML::Writer;
use IO::File;
use File::Temp qw/ tempfile tempdir /;
use File::Basename;
use File::Find;
#use File::Compare;                                                          
use Getopt::Long;                                                               
#use Pod::Usage;


my $patcher = "