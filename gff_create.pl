#!/usr/bin/perl -w
 
# GC_content_calc.pl
# This script will create new gff3s for training SNAP based on GC content. 

# Megan Bowman
# 25 June 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0  --align_gff <path to the MAKER alignment gff3> --bottom_ids <path to the bottom quartile IDs file> --upper_ids <path to the upper quartile IDs>\n";

my ($align_gff, $bottom_ids, $upper_ids);

GetOptions('align_gff=s' => \$align_gff,
	  'bottom_ids=s' => \$bottom_ids,
	  'upper_ids=s' => \$upper_ids);

if ((!defined $align_gff) || (!defined $bottom_ids) || (!defined $upper_ids)) { 
    die $usage;
}

if ((!-e $align_gff) || (!-e $bottom_ids) || (!-e $upper_ids)) {
  die $usage;
}

open IN1, "$bottom_ids" or die "Cannot open bottom quartile ids for reading\n";
open IN2, "$upper_ids" or die "Cannot open upper quartile ids for reading\n";


my ($line, %bottom_gene_id_hash, %upper_gene_id_hash, %bottom_id_hash, %upper_id_hash);

while ($line = <IN1>) {
  chomp $line;
  if ($line =~ />(.+)/) {
    my $id = $1;
    $bottom_id_hash{$id} = 1;  
  }
  if ($line =~ /^>(.+)\-mRNA\-\d$/) {
    my $gene_id = $1;
    $bottom_gene_id_hash{$gene_id} =1;
  }
}

#maker-super_120-exonerate_est2genome-gene-0.0-mRNA-2

while ($line = <IN2>) {
  chomp $line;
  if ($line =~ />(.+)/) {
    my $id = $1;
    $upper_id_hash{$id} = 1;
  }
  if ($line =~ /^>(.+)\-mRNA\-\d$/) {
    my $gene_id = $1;
    $upper_gene_id_hash{$gene_id} =1;
  }
}


open IN3, "$align_gff" or die "Cannot open alignment gff3 for reading\n";
open OUT1, ">low_GC_training_set.gff3" or die "Cannot open bottom quartile gff3 for writing\n";
open OUT2, ">high_GC_training_set.gff3" or die "Cannot open upper quartile gff3 for writing\n";

print OUT1 "##gff-version 3\n";
print OUT2 "##gff-version 3\n";

my ($contig, @elems);

while (my $line = <IN3>) {
  if ($line =~ /^\#\#FASTA$/) {
    print OUT1 $line;
    while (my $line = <IN3>) {
      print OUT1 $line;
    }
  }
  if ($line =~ /^#/) {
    next;
  }
  @elems = split "\t", $line;
  if ($elems[2] =~ /contig/) {
    $contig = $line;
    next;
  }
  if ($elems[1] =~ /maker/) {
    if ($elems[2] =~ /gene/) {
      if ($elems[8] =~ /^ID=(.+);/) {
	my $gene_id = $1;
	if (exists $bottom_gene_id_hash{$gene_id}) {
	  print OUT1 $contig;
	  print OUT1 $line;
	  $contig = "";
	  next;
	}
	if (exists $bottom_id_hash{$gene_id}) {
	  print OUT1 $contig;
	  print OUT1 $line;
	  $contig = "";
	  next;
	}
      }
    }
    if ($elems[2] =~ /mRNA/) {
      if ($elems[8] =~ /^ID=(.+);Parent=/) {
	my $gene_id = $1;
	if (exists $bottom_gene_id_hash{$gene_id}) {
	  print OUT1 $line;
	  next;
	}
	if (exists $bottom_id_hash{$gene_id}) {
	  print OUT1 $line;
	  next;
	}
      }
    }
    if (($elems[2] =~ /exon/) || ($elems[2] =~ /CDS/) || ($elems[2] =~ /five_prime_UTR/) || ($elems[2] =~ /three_prime_UTR/)) {
      if (($elems[8] =~ /Parent=(.+)$/) || ($elems[8] =~ /Parent=(.+);/) || ($elems[8] =~ /ID=(.+);/)) {
	my $parent_id = $1;
	if (exists $bottom_id_hash{$parent_id}) {
	  print OUT1 $line;
	}
	if ($parent_id =~ /,/) {
	  my @id_array = split ",", $parent_id;
	  for (my $i = 0; $i < $#id_array; $i++) {
	    if (exists $bottom_id_hash{$id_array[$i]}) {
	      print OUT1 $line;
	      next;
	    }
	    next;
	  }
	}
      }
    }
  }
}   


close IN3;

open IN3, "$align_gff" or die "Cannot open alignment gff3 for reading\n";

my ($contig2, @elems2);

while (my $line2 = <IN3>) {
  if ($line2 =~ /^\#\#FASTA$/) {
    print OUT2 $line2;
    while (my $line2 = <IN3>) {
      print OUT2 $line2;
    }
  }
  if ($line2 =~ /^#/) {
    next;
  }
  @elems2 = split "\t", $line2;
  if ($elems2[2] =~ /contig/) {
    $contig2 = $line2;
    next;
  }
  if ($elems2[1] =~ /maker/) {
    if ($elems2[2] =~ /gene/) {
      if ($elems2[8] =~ /^ID=(.+);/) {
	my $gene_id = $1;
	if (exists $upper_gene_id_hash{$gene_id}) {
	  print OUT2 $contig2;
	  print OUT2 $line2;
	  $contig2 = "";
	  next;
	}
	if (exists $upper_id_hash{$gene_id}) {
	  print OUT2 $contig2;
	  print OUT2 $line2;
	  $contig2 = "";
	  next;
	}
      }
    }
    if ($elems2[2] =~ /mRNA/) {
      if ($elems2[8] =~ /^ID=(.+);Parent=/) {
	my $gene_id = $1;
	if (exists $upper_gene_id_hash{$gene_id}) {
	  print OUT2 $line2;
	  next;
	}
	if (exists $upper_id_hash{$gene_id}) {
	  print OUT2 $line2;
	  next;
	}
      }
    }
    if (($elems2[2] =~ /exon/) || ($elems2[2] =~ /CDS/) || ($elems2[2] =~ /five_prime_UTR/) || ($elems2[2] =~ /three_prime_UTR/)) {
      if (($elems2[8] =~ /Parent=(.+)$/) || ($elems2[8] =~ /Parent=(.+);/) || ($elems2[8] =~ /ID=(.+);/)) {
	my $parent_id = $1;
	if (exists $upper_id_hash{$parent_id}) {
	  print OUT2 $line2;
	}
	if ($parent_id =~ /,/) {
	  my @id_array2 = split ",", $parent_id;
	  for (my $i = 0; $i < $#id_array2; $i++) {
	    if (exists $upper_id_hash{$id_array2[$i]}) {
	      print OUT2 $line2;
	      next;
	    }
	    next;
	  }
	}
      }
    }
  }
}  

