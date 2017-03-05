#!/usr/bin/perl -w
# This script will read the ids of two fasta files output the ids that differ between them. 
# Megan Bowman
# 21 April 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile1 <fasta file name> --fastafile2 <fasta file name> --output <output file> \n";

my ($fastafile1, $fastafile2, $in1, $in2, $output, $id1, $id2, %id_hash1, %id_hash2, $seqobj1, $seqobj2);

GetOptions('fastafile1=s' => \$fastafile1,
	   'fastafile2=s' => \$fastafile2,
	   'output=s' => \$output,);     

if (!-e $fastafile1) {
    die "$fastafile1 does not exist!\n";
}

if (!-e $fastafile2) {
    die "$fastafile2 does not exist!\n";
}
   
if (-e $output) {
    die "$output already exists!\n";
}



open OUT, ">$output" or die "\nFailed to open the output file: $!\n";

$in1  = Bio::SeqIO->new(-file => "$fastafile1", -format => 'Fasta');
$in2  = Bio::SeqIO->new(-file => "$fastafile2", -format => 'Fasta');


while ($seqobj1 = $in1 ->next_seq()) {
    $id1 = $seqobj1->display_id();
    $id_hash1{$id1} = 1;
    next;
}
while ($seqobj2 = $in2 ->next_seq()) {
    $id2 = $seqobj2->display_id();
    $id_hash2{$id2} = 1;
    next;
}

my %data_dump;

foreach my $key (keys %id_hash1) {    
  if (exists $id_hash2{$key}) {
    if (!exists $data_dump{$key}) {
      $data_dump{$key} = 1;
      next;
    }
    if (exists $data_dump{$key}) {
      next;
    }
  }
  if (!exists $id_hash2{$key}) {
    if (!exists $data_dump{$key}) {
      $data_dump{$key} = 1;
      print OUT ">$key\n";
      next;
    }
    if (exists $data_dump{$key}) {
      next;
    }
  } 
}

		      
close OUT; 
exit;
