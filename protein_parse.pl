#!/usr/bin/perl -w
 
# protein_parse.pl
# This script will input an all.maker.proteins.fasta file and output into several protein fasta files, for the purpose of breaking up a larger protein set prior to running an all vs. all blast. 

# Megan Bowman
# 26 February 2014 

use strict;
use Getopt::Long();
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --fastafile <fasta file name> \n";

my ($fastafile, $seqin);

Getopt::Long::GetOptions('fastafile=s' => \$fastafile);

if (!-e $fastafile) {
    die "$fastafile does not exist!\n";
}

if (!defined $fastafile) {
    die "You didn't define a fasta file!\n";
}

my ($seqobj, %seq_hash, $id, $desc, $seq, %desc_hash);

$seqin = Bio::SeqIO->new ( -format => 'fasta', -file => $fastafile);

while ((my $seqobj = $seqin->next_seq())) {
    $desc = $seqobj->desc();
    if ($desc =~ m/^protein/i) {
	$id = $seqobj->display_id();
	$seq = $seqobj->seq();
	$seq_hash{$id} = $seq;
	$desc_hash{$id} = $desc;
    }
}

my $count = 1;
my $check = 0;
my $key;
my @dump_array = ();

open OUT, ">protein_chunk_$count";

foreach $key (keys %seq_hash) {
    if (grep (/^$key$/, @dump_array)) {
	next;
    }
    if ($check < 9999) {
	print OUT ">$key\t" . "$desc_hash{$key}\n";
	print OUT "$seq_hash{$key}\n";
	push (@dump_array, $key);
	++$check;
	next;
    }
    if ($check == 9999) {
	print OUT ">$key\t" . "$desc_hash{$key}\n";
	print OUT "$seq_hash{$key}\n";
	push (@dump_array, $key);
	++$count;
	$check = 0;
	close OUT;
	open OUT, ">protein_chunk_$count";
	next;
    }
}
