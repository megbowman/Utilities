#!/usr/bin/perl -w
 
# protein_fasta_create.pl
# This script will create a protein fasta file given a GFF3 with functional descriptions and a protein fasta with associated IDs.   

# Megan Bowman
# 03 September 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --gff <path to seqfile.gff.dgt file> --fasta <gene feature to be identified> --output <full path of output file>\n";

my ($gff_file, $fasta, $output);

GetOptions('gff=s' => \$gff_file,
	   'fasta=s' => \$fasta,
	   'output=s' => \$output);

if (!defined ($gff_file) | !defined ($fasta) | !defined ($output)) { 
    die $usage;
}

if (!-e $gff_file) {
    die "$gff_file doesn't exist!\n"
}

if (!-e $fasta) {
    die "$fasta doesn't exist!\n"
}

if (-e $output) {
    die "$output already exists!\n"
}


#Pt      ensembl gene    3363    5604    .       -       .       ID=gene:GRMZM5G811749;biotype=protein_coding;description=30S ribosomal protein S16%2C chloroplastic  [Source:UniProtKB/Swiss-Prot%3BAcc:P27723];external_name=RPS16;logic_name=genebuilder


open IN, "$gff_file" or die "Can't open GFF3 file!\n";
open OUT, ">$output" or die "Can't open the output file for writing\n";


while (my $line = <IN>) {
 if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  if ($elems[2] =~ /^$gene$/) {
    if ($elems[8] =~/^ID=gene:(.+);biotype=(.+);description=(.+)\[Source:/) {
      $gene_id = $1;
      $description = $3;
      $gene_hash{$gene_id} = $description;
    }
  }
 foreach my $key (keys %gene_hash) {
   print OUT "$key\t$gene_hash{$key}\n";
 }
}



      

