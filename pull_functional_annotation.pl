#!/usr/bin/perl -w
 
# pull_functional_annotation.pl
# This script will pull out functional annotation lines given a list of IDs.  

# Megan Bowman
# 29 June 2015

use strict;
use Getopt::Long;


my $usage = "\nUsage: $0  --anno <annotation file> --list <path to ids> --output <path to output>\n";

my ($anno, $list, $output);

GetOptions('anno=s' => \$anno,
	   'list=s' => \$list,
	   'output=s' => \$output);
	   

if ((!defined $anno) ||  (!defined $output)) { 
    die $usage;
}

if ((!-e $anno) || (-e $output)) { 
    die $usage;
}

open IN1, "$anno" or die "Cannot open annotation file for reading\n";
open IN2, "$list" or die "Cannot open list of ids for reading\n";


open OUT1, ">$output" or die "Cannot open output for writing\n";

my (@elems, %id_hash);

while (my $line = <IN2>) {
    chomp $line;
    my $new = $line . "-mRNA-1";
    $id_hash{$new} = 1;
}

while (my $line2 = <IN1>) {
    chomp $line2;
    @elems = split "\t", $line2;
    if (exists $id_hash{$elems[0]}) {
	print OUT1 "$line2\n";
    }
}














