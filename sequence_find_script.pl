#!/usr/bin/perl -w
# This script takes as input a fasta file, a single sequence identifier and the name for an output fasta file, then finds the specific sequence in the input file and write it to the output file.
# Megan Bowman
# 14 November 2013

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --fastafile <fasta file name> --seqcheck <sequence information> --output <output file> \n";

my ($fastafile, $file1_fh, $in, $out, $output, $seqcheck);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'output=s' => \$output,
			 'seqcheck=s' => \$seqcheck,);    

if (!defined $seqcheck) {
    die "You didn't define a sequence to identify!\n";
}

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}

if (-e $output) {
    die "$output already exists!\n";
}

my ($id, $desc, $seq, $length, $seqobj, $check, $line);

$in  = Bio::SeqIO->new(-file => "$fastafile", -format => 'Fasta');
$out = Bio::SeqIO->new(-file => ">$output", -format => 'Fasta');

$check = 0; 

while ($seqobj = $in ->next_seq()) {
    $id = $seqobj->display_id();
    $desc = $seqobj->desc();
    $seq = $seqobj->seq();
    $length = $seqobj->length();
    if ($id =~/$seqcheck/) { #why isn't this working with a full sequence ID and eq?
	$out->write_seq($seqobj);
	$check = 1;
    }
}

if ($check == 0) {
    print "Sequence was not found in this file!\n";
}

exit;

