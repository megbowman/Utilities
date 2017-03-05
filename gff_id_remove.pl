#!/usr/bin/perl -w
# This script will remove duplicate base IDs in a gff3 file. 

# Megan Bowman
# 12 July 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --gff <full path to the repeats gff3 file> --output <path to output file>\n";

my ($output, $gff, %id_hash, @elems, $count);

GetOptions('gff=s' => \$gff,
	   'output=s' => \$output);     

if (!-e $gff) {
  die "$gff does not exist!\n";
}
open IN, "$gff" or die "Can't open GFF3 file!\n";
open OUT1, ">$output" or die "Can't open output file for writing\n";

$count = 1;

while (my $line = <IN>) {
  if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  if ($elems[2] eq 'match') {
    if ($elems[8] =~ /ID=(.+);Name=/) {
      my $id = $1;
      if (exists $id_hash{$id}) {
	my $change_id = $id . "_" . $count;
	my $new_elems_8 = "ID=$change_id";
	$elems[8] = $new_elems_8;
	print OUT1 "$elems[0]\t$elems[1]\t$elems[2]\t$elems[3]\t$elems[4]\t$elems[5]\t$elems[6]\t$elems[7]\t$elems[8]\n";
	++$count;
	next;
      }
      else {
	print OUT1 $line;
	$id_hash{$id} = 1;
	next;
      }
    }
    next;
  }
  else {
    next;
  }
  next;
}




