#!/usr/bin/perl -w
 
# fasta_id_truncate.pl

# This script will input a fasta file and shorten the fasta IDs for each sequence. Especially useful for when RepeatMasker doesn't like the ID name due to length.  

# Megan Bowman
# 3 January 2014

use strict;
use Getopt::Long;
use Bio::Seq;
use Bio::SeqIO;

my $usage = "\nUsage: $0 --fastafile <fasta file>\n";

my ($fastafile);

GetOptions('fastafile=s' => \$fastafile);


if (!defined ($fastafile)) {
    die $usage;
}

if (!-e $fastafile) {
    die "$repeatfile does not exist!\n"
}


my $in = Bio::SeqIO->new ( -format => 'fasta', -file => $fastafile); 
my $out = Bio::SeqIO->new (-format => 'fasta', -file => ">$fastafile_id_truncate.fasta");


while (my $seqobj = $in->next_seq()) {
    my $id = $seqobj->display_id();
    my $newid = $id; 
    $newid =~ /^(.+_.+_.+._).+$/;
    print "$newid\n";
}



# my $seq = $seqobj->seq();
#$out->write_seq($seqobj);
#}


#>CITP_longest_Locus_22593_Transcript_1/2_Confidence_0.800_Length_667
