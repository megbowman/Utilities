#!/usr/bin/perl -w
# This script will read a fasta, print to the screen print statement that will indicate the number of sequences, the total length of all sequences, and the average length of sequences. Average length should only be one decimal, and also include the N50. 

# Megan Bowman
# 18 November 2013

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name> \n";

my ($fastafile, $in, $out, $output);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'output=s' => \$output);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}

my ($check, $count, $id, %seq_length, $length, $seqobj, $total_length, $size, $average, @len, @sort_len);

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');

while ($seqobj = $in ->next_seq()) {
    $id = $seqobj->display_id();
    $length = $seqobj->length();
    $seq_length{$id} = $length;
    $total_length += $length;
    push (@len, $length);
}

$size = scalar (keys %seq_length); 

$average = $total_length/$size; 

print "Total number of sequences:\n";
print "$size\n";
print "Total length of sequences:\n";
print "$total_length\n";
print "Average length of sequence:\n"; 
printf "%.1f", $average;
print "\n"; 

@sort_len = sort {$b <=> $a} @len;

$count = 0; 
$check = 0;

for (my $i= 0; $i < @sort_len; $i++) {
    $count += $sort_len[$i];
    if ($count >= $total_length/2 && $check == 0) {
	print "N50:\n";
	print "$sort_len[$i]\n";
	$check = 1
    }
}

exit;

