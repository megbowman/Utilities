#!/usr/bin/perl -w
 
# gff_parse.pl 
# This is a test script to read in and parse a gff file for downstream analyses. 

# Megan Bowman
# 6 January 2014

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --gff <gff file name>\n";

my($gff_file);

Getopt::Long::GetOptions('gff=s' => \$gff_file);



if (!defined ($gff_file)) { 
    die $usage;
}

if (!-e $gff_file) {
    die "$gff_file doesn't exist!\n"
}


open IN, "$gff_file" or die "Failed to load gff file : $!\n";
while (my $line = <IN>) {
    chomp $line;
    if ($line =~ /^#/) {
	next;
    }
    my @elems = split "\t", $line;   
    my $id = $elems[0];
    my $repeat = $elems[2];
    print "$repeat\n";
}

close IN;


    
