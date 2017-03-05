#!/usr/bin/perl -w
 
# unidentified_nucleotide_remover.pl

# This script will input a fasta file and remove a specific designated unsupported nucleotide from the sequence, so it may be used in MAKER. This script will overwrite the original fasta file. 

# Megan Bowman
# 3 January 2014

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --fastafile <fasta file> --nucleotide <nucleotide to substitute> \n";

my ($fastafile, $nucleotide);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile,
			 'nucleotide=s' => \$nucleotide);


if (!defined ($fastafile) || !defined ($nuclotide)) { 
    die $usage;
}

if (!-e $fastafile) {
    die "$repeatfile does not exist!\n"
}


my $in = Bio::SeqIO->new ( -format => 'fasta', -file => $fastafile); 
my $out = Bio::SeqIO->new (-format => 'fasta', -file => ">$fastafile");


while (my $seqobj = $in->next_seq()) {
    my $id = $seqobj->display_id();
    my $seq = $seqobj->seq();
    my $newseq = $seq;
    $newseq =~ s/S/X/g;
    $seq = $seqobj->seq($newseq); 
    $out->write_seq($seqobj);
}

