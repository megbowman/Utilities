#!/usr/bin/perl -w
# This script takes as input a fasta file, a file containing a list of sequence identifiers and the name for an output file, then finds in the input fasta file all sequences from the sequence identifer list and writes those sequences to an output file.
# Megan Bowman
# 13 November 2013

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name> --seqcheck <sequence information> --output <output file> \n";

my ($fastafile, $file1_fh, $in, $out, $output, $seqcheck);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'output=s' => \$output,
			 'seqcheck=s' => \$seqcheck,);     

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}

if (!-e $seqcheck) {
    die "$seqcheck does not exist!\n";
}   

if (-e $output) {
    die "$output already exists!\n";
}

my ($id, %seq_hash, $desc, $seq, $length, $seqobj, $check, $input_id, $line);

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');
$out = Bio::SeqIO->new(-file => ">$output", -format => 'Fasta');

open IN, "$seqcheck" or die "\nFailed to load file of sequences to check: $!\n";

$check = 0;

while ($seqobj = $in ->next_seq()) {
    $id = $seqobj->display_id();
    $desc = $seqobj->desc();
    $seq = $seqobj->seq();
    $length = $seqobj->length();
    $seq_hash{$id} = $seqobj;
}

while ($line = <IN>) {
    chomp $line;
    if (exists $seq_hash{$line}) {
	$out->write_seq($seq_hash{$line});
	$check = 1;
    }
}
    
if ($check == 0) {
    print "Sequence was not found in this file!\n";
}

close IN;
exit;

