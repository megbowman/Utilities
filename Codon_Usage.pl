#!/usr/bin/perl -w
 
# Determine the codon usage for a given FASTA sequence. Outputs the FASTA ID for each sequence, total number of unique codons, followed by the codon usage for each sequence. 

# Megan Bowman
# 25 November 2013

use strict;
use Getopt::Long();

my $usage = "\nUsage: $0 --file <file name> \n";

my $file;

Getopt::Long::GetOptions('file=s' =>\$file);

if (!-e $file) {
    die "$file doesn't exist!\n"
}

open IN, "$file", or die "\nFailed to open file : $!\n";

my %count = ();
my $total = 0;
my $seq_to_print = 0;
my $seq;
my $line;
my $ID;
my %fasta_hash;
my $codon;
my $key;
my $i;
my $frequency; 
my $codon_number;

while ($line = <IN>) {
    chomp $line;
    if ($line =~ /^\s+$/) {
	next;
    }
    if ($line =~/^>/) {
	if ($seq_to_print == 1) {
	    if (defined ($seq)) {
		$fasta_hash{$ID} = $seq;
		    $seq = "";
	    }
	}
	if ($line =~ /^>(.+)$/) {
	    $ID = $1;
	    $seq_to_print = 1;
	}
    }
    else {
	$seq .= $line;
    }
}

$fasta_hash{$ID} = $seq;

foreach $key (keys %fasta_hash) {
    print "$key\n";
    for ($i = 0; $i < length($fasta_hash{$key}); $i+= 3) {
	$codon = substr($fasta_hash{$key}, $i, 3);
	if (exists $count{$codon}) {
	    $count{$codon}++
	}
	else {
	    $count{$codon} = 1
	}
	$total++;
    }  
    $codon_number = scalar (keys %count);
    print "Total number of unique codons: $codon_number\n";
    foreach $codon (sort keys %count) {
	$frequency = $count{$codon}/$total;
	printf "%s\t%d\t%.4f\n", $codon, $count{$codon}, $frequency;
    }
}

close IN;

exit;


