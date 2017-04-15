#!/usr/bin/perl -w
# Megan Bowman
# 15 April 2017

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name>  --output <output file> --cutoffs <Cutoff contig or scaffold size>\n";

my ($fastafile, $in, $output, $cutoffs, $out, $desc, $seq);

GetOptions('fastafile=s' => \$fastafile,
	   'output=s' => \$output,
	   'cutoffs=s' => \$cutoffs);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}
   
if (-e $output) {
    die "$output already exists!\n";
}

if (!defined $cutoffs) {
  die "$cutoffs not defined!\n";
}

my @cutoffs = split "\t", $cutoffs;


my ($seqobj, $length,$count, $id);

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');
$out  = Bio::SeqIO->new(-file => ">$output", -format => 'Fasta');

while ($seqobj = $in ->next_seq()) {
  ++$count;
  $length = $seqobj->length();
  if ($length < $cutoffs[0]) {
    next;
  }
  if ($length >= $cutoffs[0] && $length <= $cutoffs[1]) {
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

