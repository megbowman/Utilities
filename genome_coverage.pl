#!/usr/bin/perl -w
# This script will calculate the genome coverage of a particular gff3. 

# Megan Bowman
# 13 May 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --genomefile <full path to genome fasta file> --gff <full path to the repeats gff3 file>\n";

my ($genomefile, $in, $out, $output, $gff);

GetOptions('genomefile=s' => \$genomefile,
	   'gff=s' => \$gff);     

if (!-e $genomefile) {
    die "$genomefile does not exist!\n";
}

if (!-e $gff) {
    die "$gff does not exist!\n";
}

my ($check, $count, $id, %seq_length, $length, $seqobj, $total_length, $size, $average, @elems, $total_repeat_length, $genome_coverage, $seq_length, $new_length, $seq);

$in  = Bio::SeqIO->new(-file => "$genomefile", -format => 'Fasta');

while ($seqobj = $in ->next_seq()) {
  $id = $seqobj->display_id();
  $seq = $seqobj->seq();
  $seq_length = $seqobj->length();    
  my $n_count = 0;
  while ($seq =~ /([Nn]+)/g) { 
    $n_count += length($1);
  }
  $new_length = $seq_length - $n_count;
  $total_length += $new_length;
  $seq_length{$id} = $new_length;
  next;
}

$size = scalar (keys %seq_length); 

$average = $total_length/$size; 

print "Total number of sequences in genome:\n";
print "$size\n";
print "Total length of genome sequence:\n";
print "$total_length\n";
print "Average length of sequence:\n"; 
printf "%.1f", $average;
print "\n"; 


open IN, "$gff" or die "Can't open GFF3 file!\n";

while (my $line = <IN>) {
  if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  my $repeat_end = $elems[4];
  my $repeat_start = $elems[3];
  my $repeat_length = $repeat_end - $repeat_start;
  $total_repeat_length += $repeat_length;
  next;
}


$genome_coverage = ($total_repeat_length/$total_length) *100;

print "Genome coverage = $genome_coverage\n";

exit;
