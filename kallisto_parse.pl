#!/usr/bin/perl -w
# Megan Bowman

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO; 

my $usage = "\nUsage: $0 --kallisto <fasta file name> --seqcheck <sequence information> --output <output file> \n";

my ($kallisto, %seqcheck_hash, $seqcheck, $output);

GetOptions('kallisto=s' => \$kallisto,
	   'output=s' => \$output,
	   'seqcheck=s' => \$seqcheck,);    

if (!defined $seqcheck) {
    die "You didn't define a list of sequences to identify!\n";
}

if (!-e $kallisto) {
    die "$kallisto does not exist!\n";
}

if (-e $output) {
    die "$output already exists!\n";
}

open IN1, "$seqcheck" or die "\nFailed to load file of sequences to check: $!\n";
open IN2, "$kallisto" or die "\nFailed to load file of sequences to check: $!\n";
open OUT, ">$output", or die "\nFailed to open file for writing: $!\n";

my (%kallisto_hash);
 
while (my $line = <IN1>) {
    chomp $line;
    $seqcheck_hash{$line} = $line;
}    

while (my $line = <IN2>) {
    chomp $line;
    my @elems = split "\t", $line;
    $kallisto_hash{$elems[0]} = $line;
}

foreach my $key (keys %seqcheck_hash) { 
    if (exists $kallisto_hash{$key}) {
	print OUT "$kallisto_hash{$key}\n";
    }
}
   


exit;

