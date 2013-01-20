#!/usr/bin/perl

# The script is downloaded from seqanswers forum http://seqanswers.com/forums/showthread.php?t=10392 , user - kmcarr. The script is later modified by Ranjit to include help on usage and to remove unnecessary files created.



#Usage:
# pairFastq.pl <read1.fastq> <read2.fastq>

# The useful output files are 
#f1_pair
#f1_sing
#f2_pair
#f2_sing

#fastq format required
#@D5VG2KN1:111:D10BRACXX:8:1101:1442:2187 1:N:0:GGCTAC

#not work with format
#@D5VG2KN1:111:D10BRACXX:8:1101:1053:2213/1
#in this case remove /1  and /2 in all files and proceed

use strict;
use warnings;
use Data::Dumper;
use File::Basename;
use File::Spec;
use File::Temp qw/tempfile/;

$ENV{'LC_ALL'} = 'C'; # Set LOCALE environment variables to C (or POSIX) to speed up the sort command.
					  # Technically it is LC_COLLATE which effects the behavior of sort but LANG can override LC_COLLATE
					  # and LC_ALL can override everthing. This is the safest way.

my $fastq = 1; # Future option for file types other than FASTQ.
my $verbose = 0; # Make optional later.

my @temp=@ARGV;

chomp(my ($cdbfastacmd) = `which cdbfasta`);
chomp(my ($cdbyankcmd) = `which cdbyank`);
chomp(my ($catcmd) = `which cat`);
chomp(my ($sortcmd) = `which sort`);
chomp(my ($commcmd) = `which comm`);

my %inputFastq;
my %cdbindex;
my %outputFastq;
my %idxListFile;

my %progMess = ( 1 => "Index file does not exist, creating it",
				 2 => "Created index file",
				 3 => "ID list file does not exist, creating it",
				 4 => "Created full ID list file",
				 5 => "Starting sort of list file",
				 6 => "Completed sort of list file",
				 7 => "Output ID list file",
				 8 => "Output FASTQ file" );

# You may note that all of the system() calls use the scalar $cmd instead of the preferred array @cmd.
# Since many/most of the calls involve redirection of stdout, stderr or pipes I have to use a string instead of a list.
# In list context the shell redirection operators or incorrectly interpreted as parameters to pass to the command.

############
# Set up file names
############
foreach my $read ('1', '2') {
	$inputFastq{$read} = File::Spec->rel2abs(shift);
	my ($file, $dir, $suff) = fileparse($inputFastq{$read}, ".fastq");
	$cdbindex{$read} = $dir . $file . $suff . ".cidx";
	$idxListFile{$read}{'all'} = $dir . $file . "_all" . ".txt";
	foreach my $type ('sing', 'pair') {
		$idxListFile{$read}{$type} = $dir . $file . "_". $type . ".txt";
		$outputFastq{$read}{$type} = $dir . $file . "_". $type . $suff;
	}
}

############
# Create indexes and full lists
############
foreach my $read ('1', '2') {
	unless ( -e $cdbindex{$read} ) { 
		&createIdx($inputFastq{$read}, $fastq, $read);
	}
	unless ( -e $idxListFile{$read}{'all'} ) {
		&getIDs($read);
	}
	&sortList($read);
}

############
# Create pair and singleton lists
############
foreach my $type ('pair', 'sing') {
	foreach my $read ('1', '2') {
		if ($type eq 'pair' && $read eq '2') {
			system("ln $idxListFile{'1'}{'pair'} $idxListFile{'2'}{'pair'}"); # The list of paired IDs is by definition identical for both reads. Create a link to the read 1 list instead of a whol new file.
		} else {
			&commList($type, $read);
		}
	}
}

############
# Create FASTQ files
############
foreach my $type ('pair', 'sing') {
	foreach my $read ('1', '2') {
		&printFastq($type, $read);
	}
}

sub createIdx { # Calls cdbfasta to create the index file
	my ($dbFile, $fastq, $read) = @_;
	if ($verbose) { &progress(1, $read) };
	my $cmd = "$cdbfastacmd $dbFile";
	if ($fastq) { $cmd .= " -Q"};
	$cmd .= " >& /dev/null";
	system($cmd) == 0 or die "system $cmd failed: $?.";
	if ($verbose) { &progress(2, $read) };
}

sub getIDs { # Creates a text file of read ids (indexes)
	my ($read) = @_;
	if ($verbose) { &progress(3, $read) };
	my $cmd = "$cdbyankcmd $cdbindex{$read} -l > $idxListFile{$read}{'all'}"; 
	system($cmd) == 0 or die "system $cmd failed: $?.";
	if ($verbose) { &progress(4, $read) };
}

sub sortList { # Sorts the full ID list files in lexical (dictionary) order, required to use comm command.
	my ($read) = @_;
	my $template = "tmpsort_XXXX";
	my ($fh, $tmp) = tempfile($template, UNLINK=>1);
	my @cmd = ($sortcmd, "-S", "10G", "-o", $tmp, $idxListFile{$read}{'all'});
	if ($verbose) { &progress(5, $read) };
	system(@cmd) == 0 or die "system @cmd failed: $?.";
	@cmd = ("mv", $tmp, $idxListFile{$read}{'all'});
	system(@cmd) == 0 or die "system @cmd failed: $?.";
	if ($verbose) { &progress(6, $read) };
}

sub commList {
	my ($type, $read) = @_;
	my $cmd = $commcmd;
	if ($type eq 'pair') {
		$cmd .= " -12";
	} elsif ($read eq '1') {
		$cmd .= " -23";
	} else {
		$cmd .= " -13";
	}
	$cmd .= " $idxListFile{'1'}{'all'} $idxListFile{'2'}{'all'} > $idxListFile{$read}{$type}";
	system($cmd) == 0 or die "system $cmd failed: $?.";
	if ($verbose) { &progress(7, $read, $type) };
}

sub printFastq {
	my ($type, $read) = @_;
	system("$catcmd $idxListFile{$read}{$type} | $cdbyankcmd $cdbindex{$read} -o $outputFastq{$read}{$type}");
	if ($verbose) { &progress(8, $read, $type) };
}

sub progress {
	my ($message, $read, $type) = @_;
	print STDERR scalar(localtime(time));
	print STDERR " $progMess{$message} for read #$read";
	print STDERR " $type" if (defined $type);
	print STDERR ".\n";
}

system("rm *_all.txt");
system("rm *.cidx");
system("rm *_pair.txt");
system("rm *_sing.txt");
#my $ttt="rm ".$temp[0]."_all.txt";
#system($ttt);
#$ttt="rm $temp[1]"."_all.txt";
#system($ttt);
#$ttt="rm $temp[0]".".cidx";
#system($ttt);
#$ttt="rm $temp[1]".".cidx";
#system($ttt);
#$ttt="rm $temp[0]"."_pair.txt";
#system($ttt);
#$ttt="rm $temp[1]"."_pair.txt";
#system($ttt);
#$ttt="rm $temp[0]"."_sing.txt";
#system($ttt);
#$ttt="rm $temp[1]"."_sing.txt";
#system($ttt);






