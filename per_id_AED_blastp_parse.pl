#!/usr/bin/perl -w
 
# per_AED_blastp_parse.pl 
# This script will parse the results of a blastp analysis looking at AED=1 gene models and will output the top hit. 

# Megan Bowman
# 07 April 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;
use Bio::SearchIO;

my $usage = "\nUsage: $0 --blastp <blastp output file> --piden <percent identity> --pcov <percent coverage> --no_hit <name of no hit output file> --AEDlt1_hit <name of AED less than 1 hit output file> --AED1_hit <name of AED 1 hit output file>\n";

my ($blastp, $pcoverage, $pidentity, $AEDlt1, $no_hit, $AED1hit);


GetOptions('blastp=s' => \$blastp,
	   'piden=i' => \$pidentity,
	   'pcov=i' => \$pcoverage,
	   'no_hit=s' => \$no_hit,
	   'AEDlt1_hit=s' => \$AEDlt1,
	   'AED1_hit=s' => \$AED1hit);
 
if (!defined $blastp) { 
  die "You didn't define the blastp results\n";
}

if (!-e $blastp) {
  die "$blastp doesn't exist!\n";
}

if (!defined ($pcoverage) || !defined ($pidentity)) {
  $pcoverage = 90;
  $pidentity = 80;
}


my $out_blast = Bio::SearchIO->new ( -format =>'blast', -file => "$blastp");

open OUT1, ">$no_hit" or die "Can't open no hit blastp file\n";
open OUT2, ">$AED1hit" or die "Can't open AED1hit blastp file\n";
open OUT3, ">$AEDlt1" or die "Can't open AEDlt1hit blastp file\n";

my (@iden1, @hsp_indiv1, $check, $total_hsp1);

while (my $result = $out_blast ->next_result()) { 
  my $query_name = $result->query_name();
  my $query_desc = $result->query_description();
  my $query_length1 = $result->query_length();
  if ($query_desc =~ /^protein\sAED:(\d.\d+)\s/) {
    my $AED1 = $1;
    if ($AED1 == 1) {
      my $num_hits1 = $result->num_hits();
      if ($num_hits1 == 0) {
	print OUT1 "$query_name\t$query_desc\n";
	next;
      }
      if ($num_hits1 > 0) {
	$check = 0;
	while (my $hit = $result->next_hit()) {
	  my $hit_name = $hit->name();
	  my $hit_desc = $hit->description();
	  if ($hit_name eq $query_name && $hit_desc eq $query_desc) {
	    next;
	  }
	  if ($hit_desc =~ /^protein\sAED:(\d.\d+)\s/) {
	    if ($check <= 3) {
	      my $AED2 = $1;
	      while (my $hsp = $hit->next_hsp) {
		my $frac_identical = $hsp->frac_identical();
		push(@iden1, $frac_identical);
		my $hsp_ind_len1 = $hsp->length('query');
		$total_hsp1 += $hsp_ind_len1;
		push(@hsp_indiv1, $hsp_ind_len1);
	      }
	      my $percent_coverage = ($total_hsp1/$query_length1) * 100;  
	      my $percent_identity = 0;
	      for my $i1 (0..$#hsp_indiv1) {
		$percent_identity += (($hsp_indiv1[$i1]/$total_hsp1) * $iden1[$i1]) * 100;  
	      }
	      if ($percent_identity >= $pidentity && $percent_coverage >= $pcoverage) {
		$check++;	      
		if ($AED2 == 1) {
		  print OUT2 "Query Name:" . "\t" . "$query_name" . "\t" . "$query_desc\n";
		  print OUT2 "Hit Name:" . "\t" . "$hit_name" . "\t" . "$hit_desc\n";
		  next;
		}
		if ($AED2 > 0 && $AED2 < 1) {
		  print OUT3 "Query Name:" . "\t" . "$query_name" . "\t" . "$query_desc\n";
		  print OUT3 "Hit Name:" . "\t" . "$hit_name" . "\t" . "$hit_desc\n";
		  next;
		}
	      }
	      else {
		$check++;	      
		last;
	      }
	    }
	    else {
	      last;
	    }
	  }
	  else {
	    last;
	  }
	}
      }
    }    
  }
}

