#!/usr/bin/perl -w
 
# fasta_id_format.pl

# This script will input a fasta file and change the IDs for each sequence, specified by the user.  

# Megan Bowman
# 07 May 2015

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --fastafile <fasta file> --id <name for contigs> --output <output file>\n";

my ($fastafile, $id, $output);

GetOptions('fastafile=s' => \$fastafile,
	   'id=s' => \$id,
	   'output=s' => \$output);


if (!defined ($fastafile)) {
    die $usage;
}

if (!defined ($id)) {
    die "You need to give an identifer for the sequences\n";
}

if (!-e $fastafile) {
    die "$fastafile does not exist!\n"
}

if (-e $output) {
    die "$output already exists!\n"
}

my $in = Bio::SeqIO->new ( -format => 'fasta', -file => $fastafile); 
my $out = Bio::SeqIO->new (-format => 'fasta', -file => ">$output");

my $count = 0;

while (my $seqobj = $in->next_seq()) {
    ++$count;
    my $new_id = $id . "_" . "contig_" . "$count";
    my $replaced_id = $seqobj->display_id($new_id);
    $out->write_seq($seqobj);
}


