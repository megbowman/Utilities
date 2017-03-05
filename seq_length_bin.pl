#!/usr/bin/perl -w
# This script will find the lengths of contigs and then count of number of contigs within each designated bin. Output can be easily read in excel for graphing if need be. 
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

my ($seqobj, $length, $bin1, $bin2, $bin3, $bin4, $bin5, $bin6, $bin7, $bin8, $count, $bin9, $bin10, $bin11, $bin12, $len_200, $len_500, $len_1000, $len_2000);

open OUT, ">$output" or die "\nFailed to open the output file: $!\n";

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');

print OUT "Length (bp)" . "\t" . "Number" . "\n";

while ($seqobj = $in ->next_seq()) {
  $length = $seqobj->length();
  ++$count;
  if ($length >= 1000000) {
    ++$bin9;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 999999 && $length >= 100000) {
    ++$bin10;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 99999 && $length >= 50000) {
    ++$bin11;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 49999 && $length >= 10000) {
    ++$bin12;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 9999 && $length >= 5000) {
    ++$bin1;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 4999 && $length >= 4000) {
    ++$bin2;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 3999 && $length >= 3000) { 
    ++$bin3;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 2999 && $length >= 2000) {
    ++$bin4;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    $len_2000 += $length;
    next;
  }
  if ($length <= 1999 && $length >= 1000) {
    ++$bin5;
    $len_200 += $length;
    $len_500 += $length;
    $len_1000 += $length;
    next;
  }
  if ($length <= 999 && $length >= 500) {
    ++$bin6;
    $len_200 += $length;
    $len_500 += $length;
    next;
  }
  if ($length <= 499 && $length >= 200) {
    ++$bin7;
    $len_200 += $length;
    next;
  }
  if ($length <= 199 && $length >= 0) {
    ++$bin8;
    next;
  }
}



if ($bin9 >= 1) {
  print OUT "1000000 or greater" . "\t" . "$bin9" . "\n";
}
else {
  print OUT "1000000 or greater" . "\t" . "0" . "\n";
}
if ($bin10 >= 1) {
  print OUT "999999 to 100000" . "\t" . "$bin10" . "\n";
}
else {
  print OUT "999999 to 100000" . "\t" . "0" . "\n";
}
if ($bin11>= 1) {
  print OUT "99999 to 50000" . "\t" . "$bin11" . "\n";
}
else {
  print OUT "99999 to 50000" . "\t" . "0" . "\n";
}
if ($bin12>= 1) {
  print OUT "49999 to 10000" . "\t" . "$bin12" . "\n";
}
else {
  print OUT "49999 to 10000" . "\t" . "0" . "\n";
}
if ($bin1 >= 1) {
  print OUT "9999 to 5000" . "\t" . "$bin1" . "\n";
}
else {
  print OUT "9999 to 5000" . "\t" . "0" . "\n";
}
if ($bin2 >= 1) {
  print OUT "4999 to 4000" . "\t" . "$bin2" . "\n";    
}
else {
  print OUT "4999 to 4000" . "\t" . "0" . "\n";
}

if ($bin3 >= 1) {
  print OUT "3999 to 3000" . "\t" . "$bin3" . "\n";
}
else {
  print OUT "3999 to 3000" . "\t" . "0" . "\n";
}
if ($bin4 >= 1) {
  print OUT "2999 to 2000" . "\t" . "$bin4" . "\n";
}
else {
  print OUT "2999 to 2000" . "\t" . "0" . "\n";
}
if ($bin5 >= 1) {
  print OUT "1999 to 1000" . "\t" . "$bin5" . "\n";
}
else {
  print OUT "1999 to 1000" . "\t" . "0" . "\n";
}
if ($bin6 >= 1) {
  print OUT "999 to 500" . "\t" . "$bin6" . "\n";
}
else {
  print OUT "999 to 500" . "\t" . "0" . "\n";
}
if ($bin7 >= 1) {
  print OUT "499 to 200" . "\t" . "$bin7" . "\n";
}
else {
  print OUT "499 to 200" . "\t" . "0" . "\n";
}
if ($bin8 >= 1) {
  print OUT "199 to 0" . "\t" . "$bin8" . "\n";
}
else {
  print OUT "199 to 0" . "\t" . "0" . "\n";
}

print OUT "Total number of scaffolds sorted:" . "\t" . "$count" . "\n";
print OUT "Length of sequence greater than 200bp:" . "\t" . "$len_200" . "\n";
print OUT "Length of sequence greater than 500bp:" . "\t" . "$len_500" . "\n";
print OUT "Length of sequence greater than 1000bp:" . "\t" . "$len_1000" . "\n";
print OUT "Length of sequence greater than 2000bp:" . "\t" . "$len_2000" . "\n";



close OUT;
exit;

