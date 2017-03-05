#!/usr/bin/perl -w
# This script will read one fasta file and write to a new fasta file just the identifers and length of each sequence. 
# Megan Bowman
# 15 November 2013

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name>  --output <output file> \n";

my ($fastafile, $in, $output);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'output=s' => \$output,);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}
   
if (-e $output) {
    die "$output already exists!\n";
}

my ($id, $seqobj, $length);

open OUT, ">$output" or die "\nFailed to open the output file: $!\n";

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');

while ($seqobj = $in ->next_seq()) {
    $id = $seqobj->display_id();
    $length = $seqobj->length();
    print OUT "$id\n$length\n";
    
}

close OUT;
exit;

