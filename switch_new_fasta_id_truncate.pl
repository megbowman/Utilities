#!/usr/bin/perl -w
 
# fasta_id_truncate.pl

# This script will input a fasta file and shorten the fasta IDs for each sequence. Especially useful for when RepeatMasker doesn't like the ID name due to length.  

# Megan Bowman
# 3 January 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --fastafile <fasta file> --output <path to output file>\n";

my ($fastafile, $output, $new_id);

GetOptions('fastafile=s' => \$fastafile);


if (!defined ($fastafile)) {
    die $usage;
}

if (!-e $fastafile) {
    die "$fastafile does not exist!\n"
}


my $in = Bio::SeqIO->new ( -format => 'fasta', -file => $fastafile); 
my $out = Bio::SeqIO->new (-format => 'fasta', -file => ">$output");


while (my $seqobj = $in->next_seq()) {
  my $id = $seqobj->display_id();
  if ($id =~ /^(.+_.+).+(\(.+)$/) {
    $new_id = "$1" . "$2";
  }
  my $change_id = $seqobj->display_id($new_id);
  $out->write_seq($seqobj);
}


#>101078_101078_1_SW_CLONE_107853_107853_1_SW_CLONE  (dbseq-nr 128433) [45756,52251]
