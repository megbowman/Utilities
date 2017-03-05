#!/usr/bin/perl -w
# This script will read one fasta file and write to a new fasta file just the identifer of those sequences bigger than a specific length. 
# Megan Bowman
# 15 November 2013

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name> --seq_length <length> --output <output file> \n";

my ($fastafile, $file1_fh, $in, $out, $output, $seq_length);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'output=s' => \$output,
			 'seq_length=i'=> \$seq_length,);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}

if (!defined $seq_length) {
    die "You didn't define a length!\n";
}   

if (-e $output) {
    die "$output already exists!\n";
}

my ($id, %hash1, %hash2, $desc, $seq, $length, $seqobj, $check, $key);

open OUT, ">$output" or die "\nFailed to open the output file: $!\n";

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');

$check = 0;

while ($seqobj = $in ->next_seq()) {
    $id = $seqobj->display_id();
    $desc = $seqobj->desc();
    $seq = $seqobj->seq();
    $length = $seqobj->length();
    if ($length > $seq_length) {
	print OUT "$id\n";
	$check = 1;
    }
}
    
if ($check == 0) {
    print "There are no sequences in this fasta file greater than that length.\n";
}


close OUT;
exit;

