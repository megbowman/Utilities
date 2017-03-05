#!/usr/bin/perl -w
 
# find_feature_gff.pl
# This script will find a particular feature in a gff3 and write the approprite features into a new gff3 file. 

# Megan Bowman
# 13 January 2014

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --gff <path to seqfile.gff.dgt file> --feature <gene feature to be identified> --output <full path of output file>\n";

my ($gff_file, $feature, $output);

Getopt::Long::GetOptions('gff=s' => \$gff_file,
			'feature=s' => \$feature,
			'output=s' => \$output);

if (!defined ($gff_file) | !defined ($feature) | !defined ($output)) { 
    die $usage;
}

if (!-e $gff_file) {
    die "$gff_file doesn't exist!\n"
}

if (-e $output) {
    die "$output already exists!\n"
}

open IN, "$gff_file" or die "Can't open GFF3 file!\n";
open OUT, ">$output" or die "Can't open the output file for writing\n";

my (@elems, $feat_count);

while (my $line = <IN>) {
  if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  if ($elems[2] =~ /^$feature$/) {
    ++$feat_count;
    print OUT $line;
  }
}

print "Number of features in this GFF:$feat_count\n";

