#!/usr/bin/perl -w
 
#  This script will add the allele frequencies line by line for phylip data set development. 

# Megan Bowman
# 24 November 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --file <path to file name> --output <full path to output file>\n";

my ($file, $output);

GetOptions('file=s' => \$file,
	   'output=s' => \$output);

open OUT, ">$output" or die "Can't open output file!\n";
open IN, "$file" or die "Can't open input file!\n";

while ($line = <IN1>) {
  chomp $line;
  print OUT "$line\n";
}
