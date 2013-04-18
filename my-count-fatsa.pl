#!/usr/bin/perl
#usage perl program.pl input>output

use warnings;
use strict;

my $fastaFile = shift;
open (FASTA, "<$fastaFile");
$/ = ">";

my $junkFirstOne = <FASTA>;

while (<FASTA>) {
        chomp;
        my ($def,@seqlines) = split /\n/, $_;
        my $seq = join '', @seqlines;
        my $length=length($seq);
        #print "$def\t$length\t$seq\n";
        print "$def\t0\t$length\n";
}

