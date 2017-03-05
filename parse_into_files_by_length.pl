#!/usr/bin/perl -w
# This script will find the lengths of scaffolds and then count of number of contigs within each designated bin. Output can be easily read in excel for graphing if need be. 
# Megan Bowman
# 21 April 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name>  --output <output file> --cutoff <Cutoff contig or scaffold size>\n";

my ($fastafile, $in, $output, $cutoff, $out, $desc, $seq);

GetOptions('fastafile=s' => \$fastafile,
	   'output=s' => \$output,
	   'cutoff=i' => \$cutoff);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}
   
if (-e $output) {
    die "$output already exists!\n";
}

if (!defined $cutoff) {
  die "$cutoff not defined!\n";
}

my ($seqobj, $length,$count, $id);

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');
$out  = Bio::SeqIO->new(-file => ">$output", -format => 'Fasta');

while ($seqobj = $in ->next_seq()) {
  ++$count;
  $length = $seqobj->length();
  if ($length < $cutoff) {
    next;
  }
  if ($length >= $cutoff) {
    $id = $seqobj->display_id();
    $desc = $seqobj->desc();
    $seq = $seqobj->seq();
    $out->write_seq($seqobj);
    next;
  }
  $out->write_seq($seqobj);
  next;
}

print "Total number of scaffolds sorted:" . "\t" . "$count" . "\n";

exit;

