#!/usr/bin/perl -w
 
# create_functional_annotation.pl
# This script will create a functional annotation given maize blast results and database, rice blast results and database, and pfam results.   
# Some of this code was borrowed from Kevin Childs - create_functional_annotation_for_cleome.pl

# Megan Bowman
# 09 September 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

my $usage = "\nUsage: $0 --rice_annotation_database <path to fasta used to create rice blast database> --rice_blast_results <path to rice blast results> --maize_annotation_database <path to fasta used to create maize blast database> -- maize_blast_results <path to rice blast results> --proteins <path to maker standard proteins> --pfam_results <path to pfam results> --max_hits <number of hits to use> --output_file <path to final output file>\n";

my ($rice_anno, $rice_blast, $maize_anno, $maize_blast, $pfam, $max_hits, $output, $protein);

GetOptions('rice_annotation_database=s' => \$rice_anno,
           'rice_blast_results=s'=> \$rice_blast,
           'maize_annotation_database=s' => \$maize_anno,
           'maize_blast_results=s' => \$maize_blast, 
           'pfam_results=s' => \$pfam, 
           'max_hits=i' => \$max_hits,
           'output_file=s' => \$output,
           'proteins=s' => \$protein);

if (!defined ($rice_anno) | !defined ($rice_blast) | !defined ($maize_anno) | !defined ($maize_blast) | !defined ($pfam) | !defined ($max_hits) | !defined ($protein) | !defined ($output)) { 
    die $usage;
}

if (!-e $rice_anno) {
    die "$rice_anno doesn't exist!\n"
}

if (!-e $rice_blast) {
    die "$rice_blast doesn't exist!\n"
}

if (!-e $maize_anno) {
    die "$maize_anno doesn't exist!\n"
}

if (!-e $maize_blast) {
    die "$maize_blast doesn't exist!\n"
}

if (!-e $protein) {
    die "$protein doesn't exist!\n"
}

if (-e $output) {
    die "$output already exists!\n"
}


my ($in1, $in2, $in3, %maker_standard, %maize_db_seqs, %rice_db_seqs, $searchio_maize, $searchio_rice, %annotations);

print "Gathering maize data..\n";

$in1  = Bio::SeqIO->new(-file => "$maize_anno", -format => 'Fasta');

while (my $seqobj = $in1 ->next_seq()) {
  my $id = $seqobj->display_id();
  my $desc = $seqobj->desc();
  if (!defined ($desc)) {
    die "\nThe sequence " . $seqobj->display_id() . " does not have a description.\n\n";
  }
  my $new_info = "$id\t$desc" . "(Ortholog)";
  $maize_db_seqs{$id} = $new_info;
}

print "Gathering rice data..\n";

$in2  = Bio::SeqIO->new(-file => "$rice_anno", -format => 'Fasta');

while (my $seqobj = $in2 ->next_seq()) {
  my $id2 = $seqobj->display_id();
  my $desc2 = $seqobj->desc();
  if (!defined ($desc2)) {
    die "\nThe sequence " . $seqobj->display_id() . " does not have a description.\n\n";
  }
  my $new_info = "$id2\t$desc2" . "(Homolog)";
  $rice_db_seqs{$id2} = $new_info;
}

print "Gathering maker standards..\n";

$in3  = Bio::SeqIO->new(-file => "$protein", -format => 'Fasta');

while (my $seqobj = $in3 ->next_seq()) {
  my $id3 = $seqobj->display_id();
  $maker_standard{$id3} = 1;
}


print "Searching through rice blast output...\n";

$searchio_rice = Bio::SearchIO->new(-format => 'blast', -file => $rice_blast);
while (my $result = $searchio_rice->next_result()) {
  my $query_name = $result->query_name;
  my $annotation;
  my $hit_counter = 0;
  while (my $hit = $result->next_hit) {
    my $subject_name = $hit->name;
    $hit_counter++;
    $annotation = $rice_db_seqs{$subject_name};
    if (defined($annotation) || $hit_counter >= $max_hits) {
      last;
    }        
  }
  if (!defined($annotation) || $annotation eq 'protein|expressed protein') {
    if ($hit_counter >= 1) {
      $annotation = "N/A" . "\t" . "Conserved expressed gene of unknown function";
    } 
    else {
      $annotation = "N/A" . "\t" . "Gene of unknown function";
    }
  }
  $annotations{$query_name} = $annotation;
}

print "Searching through maize blast output...\n";


$searchio_maize = new Bio::SearchIO->new(-format => 'blast', -file => $maize_blast);
while (my $result = $searchio_maize->next_result()) {
  my $query_name = $result->query_name;
  my $annotation;
  my $hit_counter = 0;
  while (my $hit = $result->next_hit) {
    my $subject_name = $hit->name;
    $hit_counter++;
    $annotation = $maize_db_seqs{$subject_name};
    if (defined($annotation) || $hit_counter >= $max_hits) {
      last;
    }
  }        
  if (!defined($annotation) || $annotation eq 'protein|expressed protein') {
    if ($hit_counter >= 1) {
      $annotation = "N/A" . "\t" . "Conserved expressed gene of unknown function";
    } 
    else {
      $annotation = "N/A" ."\t" ."Gene of unknown function";
    }
  }
  if (!exists ($annotations{$query_name})) {
    $annotations{$query_name} = $annotation;
  }
  next;
}


print "Searching through pfam results...\n";


my %pfam_matched_genes;
open PFAM, $pfam or die "\nUnable to open pfam results file: $pfam\n\n";
while ( my $line = <PFAM> ) {
  chomp $line;
  if ($line =~ /^#/) {
    next;
  }
  $line =~ s/\s+/\t/g;
  my @first_elems = split "\t", $line;
  my @elems = splice(@first_elems, 0, 18);
  
  my $annotation = join " ", @first_elems;
  my $query_name = $elems[2];
  my $score = $elems[4];
  if (!exists($maker_standard{$query_name})) {
    next;
  }
  if (!exists ($annotations{$query_name}) || $annotations{$query_name} !~ /Uncharacterized protein/) {
    next;
  }
  if ($score > 1e-10) {
    next;
  }
  if ($annotation =~ /^(.+?)\s+Molecular Function:/) {
    $annotation = $1;
  }
  if ($annotation =~ /Protein of unknown function,* \(*(DUF\d+)\)*/) {
    $annotation = $1;
  }
  if ($annotation =~ /Domain of unknown function,* \(*(DUF\d+)\)*/) {
    $annotation = $1;
  }
  $annotation =~ s/ domain$//;
  my $new_annotation = "N/A" . "\t" . "$annotation";
  $annotations{$query_name} = $new_annotation;
}


my %dump_hash;

print "Printing final output...\n";


open OUT, ">$output" || die "\nUnable to open $output for writing.\n\n";
foreach my $id (keys(%annotations)) {
  print OUT "$id\t$annotations{$id}\n";
  next;
}

print "Done!\n";


close OUT;

exit;

