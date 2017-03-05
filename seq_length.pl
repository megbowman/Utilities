#!/usr/bin/perl -w
# This script will find the lengths of contigs.
# Megan Bowman
# 19 March 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name>  --output <output file> \n";

my ($fastafile, $in, $output);

GetOptions('fastafile=s' => \$fastafile,
	   'output=s' => \$output,);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}
   
if (-e $output) {
    die "$output already exists!\n";
}

my ($seqobj, $length);

open OUT, ">$output" or die "\nFailed to open the output file: $!\n";

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');

print OUT "Name" . "\t" . "Length" . "\n";

while ($seqobj = $in ->next_seq()) {
  my $length = $seqobj->length();
  my $id = $seqobj->display_id();
  print OUT "$id\t$length\n";
}
 
