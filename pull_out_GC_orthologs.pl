#! /usr/bin/perl

# pull_out_GC_orthologs.pl


# Megan Bowman
# 17 July 2015

use strict;
use warnings;
use Getopt::Long;

my ($input, $out, $help, $anno, $pfam, $fpkm, $list);


my $usage = "\n$0\n --input_file <input file name> --list <list of unique_genes> --pfam <pfam results file> --fpkm <fpkm sum file> --anno <functional annotation file> --output_file <output file name>\n";

GetOptions("input_file=s" => \$input,
	   "pfam=s" => \$pfam,
	   "fpkm=s" => \$fpkm,
	   "anno=s" => \$anno,
	   "output_file=s" => \$out,
	   "list=s" => \$list,
	   "help" => \$help)   or die("Error in command line arguments\n");


if (defined($help)) {
    print $usage;
    exit;
}

if (!defined($input) || !defined($out) || !defined($pfam) || !defined($fpkm) || !defined($anno) || !-e ($input) || -e ($out)) {
    die $usage;
}
   
  
open my $file1, "$input" or die "cant open input file";
open my $file2, "$anno" or die "Can't open annotation file";
open my $file3, "$fpkm" or die "Can't open FPKM file";
open my $output1, ">$out" or die "cant open output";
open my $file4, "$list" or die "can't open list";

my (%anno_hash, $real_id, %fpkm_hash, $species, %uniq_hash);


while (my $line = <$file2>) {
    chomp $line;
    my @elems = split /\t/, $line;
    $anno_hash{$elems[0]} = $elems[2];
}

while (my $line = <$file3>) {
    chomp $line;
    my @elems = split /\t/, $line;
    $fpkm_hash{$elems[0]} = $elems[1];
}

while (my $line = <$file4>) {
    chomp $line;
    my @elems = split /\t/, $line;
    $uniq_hash{$elems[0]} = 1;
}


open PFAM, $pfam or die "\nUnable to open $pfam for reading.\n\n";

my %pfam_genes;

while (my $line = <PFAM>) {
    chomp $line;
    if ($line =~ /^#/) {
        next;
    }
    $line =~ s/\s+/\t/g;
    my @elems = split "\t", $line;
    if ($elems[4] <= 1E-10) {
	my $data = $elems[18];
        $pfam_genes{$elems[2]} = $data;
    }
}
close PFAM;

print $output1 "Ortho\tTaxa\tCombo\tBrachy\tMaize\tSorghum\tUnique\tID\tAnno\tPfam\tFPKM\n";

my @ids;

my $rice_count = 0;
my $maize_count = 0;
my $sorghum_count = 0;
my $brachy_count = 0;
my $count = 0;
my $newcount = 0;


while (my $line = <$file1>) {
    my $rice_count = 0;
    my $maize_count = 0;
    my $sorghum_count = 0;
    my $brachy_count = 0;
    my $count = 0;
    chomp $line;
    my @temp = split /\t/, $line;
    my @data = split /\s/, $temp[1];
    foreach my $id (@data) {
	if ($id eq "") {
	    next;
	}
	if ($id =~ /^(.+)\((.+)\)/) {
	    $real_id = $1;
	    $species = $2;
	    if (exists $uniq_hash{$real_id}) {
		print "Unique!\t$real_id\n";
		push @ids, $real_id;
		++$count;
		++$newcount;
	    }
	    elsif (!exists $uniq_hash{$real_id} && $real_id =~ /MAKER/) {
		print "Boo!\t$real_id\n";
	    }
	    if ($species eq 'Os_MAKER_COMBO') {
		++$rice_count;
	    }
	    if ($species eq 'Brachypodium_distachyon') {
		++$brachy_count;
	    }
	    if ($species eq 'Zea_mays_B73') {
		++$maize_count;
	    }
	    if ($species eq 'Sorghum_bicolor') {
		++$sorghum_count;
	    
	    }
	}
    }
    
    if ($count == 0) {
	$rice_count = 0;
	$maize_count = 0;
	$sorghum_count = 0;
	$brachy_count = 0;
	$count = 0;
	next;
    }
    if ($count > 0) {
	$temp[0] =~ /^(ORTHOMCL\d+)\(.+,(\d+)\staxa\):/;

	foreach my $point (@ids) {
	    
	    if (exists $anno_hash{$point}) {
		
		if (exists $fpkm_hash{$point}) {
		    
		    if (exists $pfam_genes{$point}) {
			
			print $output1 "$1\t$2\t$rice_count\t$brachy_count\t$maize_count\t$sorghum_count\t$count\t$point\t$anno_hash{$point}\t$pfam_genes{$point}\t$fpkm_hash{$point}\n";
			$rice_count = 0;
			$maize_count = 0;
			$sorghum_count = 0;
			$brachy_count = 0;
			$count = 0;
			@ids = "";
			next;
		    }
		    
		    else {
			
			print $output1 "$1\t$2\t$rice_count\t$brachy_count\t$maize_count\t$sorghum_count\t$count\t$point\t$anno_hash{$point}\tN/A\t$fpkm_hash{$point}\n";
			$rice_count = 0;
			$maize_count = 0;
			$sorghum_count = 0;
			$brachy_count = 0;
			$count = 0;
			@ids = "";
			next;	
		    }
		    next;
		}
		next;
	    }
	    next;
	}
	next;
    }
    next;
}
    

    
print "Number of GC specific genes in orthologous groups:$newcount\n";


#<$file1> line 8735.

#ORTHOMCL0(1189 genes,1 taxa):










    
