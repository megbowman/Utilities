#!/usr/bin/perl -w
 
# GC_content_calc.pl
# This script will identify est2genome aligned regions in a genome and calculate the GC content. Quartiles of GC content are created. 

# Megan Bowman
# 13 June 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use POSIX;

my $usage = "\nUsage: $0 --gff <path to MAKER alignment gff3> --sequencefile <full path to whole genome sequence> --est2genome <name of file for est2genome output>\n";

my ($gff_file, $feature, $output, $est2genome, $sequencefile);

GetOptions('gff=s' => \$gff_file,
	   'est2genome=s' => \$est2genome,
	   'sequencefile=s' => \$sequencefile);

if (!defined ($gff_file) | !defined ($est2genome) | !defined ($sequencefile)) { 
    die $usage;
}

if (!-e $gff_file) {
    die "$gff_file doesn't exist!\n"
}

if (-e $est2genome) {
    die "$est2genome already exists!\n"
}

if (!-e $sequencefile) {
    die "$sequencefile doesn't exist!\n"
}

open IN, "$gff_file" or die "Can't open GFF3 file!\n";
open OUT, ">$est2genome" or die "Can't open the output file for writing\n";

my (@elems, $feat_count, %data_start, %data_end, @id_array);

while (my $line = <IN>) {
  if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  if ($elems[1] =~ /^est2genome$/) {
    if ($elems[2] =~ /^expressed_sequence_match$/) {
      $elems[3] = $est_start;
      $elems[4] = $est_finish;
      $elems[0] = $id;
      $new_id = $elems[0] . "_" . $est_start;
      my $est_start = %data_start{$new_id};
      my $est_end =  %data_end{$new_id};
      my $id = %id_hash{$new_id};
      push (@id_array, $new_id);
    }
    else {
      next;
    }
  }
  else {
    next;
  }
}

my $seqin = Bio::SeqIO->new ( -format => 'fasta', -file => $sequencefile);


while ($seqobj = $seqin->next_seq()) {
    $id = $seqobj->display_id();
    $length = $seqobj->length();
    $sequencehash{$id} = $seqobj;
    $lengthhash{$id} = $length;
}

foreach my $key (keys %sequencehash) { 
  for ($i= 0; $i < $#id_array; $i++) {
    if ($key eq $id_hash{$id_array[$i]}) {
       $seq = $sequencehash{$key}->subseq($data_start{$id_array[$i]}, $data_end{$id_array[$i]}); 
       print OUT "$id_array[$i]\n";
       print OUT "$seq\n";
       next;
     }
  }
}
    
my %seq_objects;

my $fasta = Bio::SeqIO->new (-format => 'fasta', -file => $est2genome);

my ($gc_count, $gc_percent, %gc_hash);

while (my $seqobj2 = $fasta->next_seq()) {
  my $fastaseq = $seqobj2->seq();
  my $seq_id = $seqobj2->display_id();
  $seq_objects{$seq_id} = $seqobj2;
  while ($fasta =~ /([GC]+)/g) {
    $gc_count += length($1);
  }
  my $seq_length = $seqobj2 ->length();
  my $gc_percent = ($gc_count/$seq_length) * 100;
  %gc_hash{$seq_id} = $gc_percent;
}

my $bottom_seqio = Bio::SeqIO->new (-format => 'fasta', -file => ">bottom_quartile_GC_content.fasta");
my $top_seqio = Bio::SeqIO->new (-format => 'fasta', -file => ">top_quartile_GC_content.fasta");

my @sorted_ids = sort mysort keys %gc_hash;
$count = scalar @sorted_ids;
my $bottom_quartile = floor ($count/4);
my $upper_quantile = $count - $bottom_quantile;

for (my $i = 0; $i < $bottom_quartile; ++$i) {
  $bottom_seqio->write_seq($seq_objects{$sorted_ids[$i]});
}

for (my $i = $upper_quartile; $i <= $count; ++$i) {
  $top_seqio->write_seq($seq_objects{$sorted_ids[$i]});
}

exit 0;

sub mysort {
  return $gc_hash{$a} <=> $gc_hash{$b};
}






  
    


      
  
  
  

