
#!/bin/bash

#-------------------------------------------------------------------------
# Name - blast-coverage.sh
# Desc - The program will find all blast hits for file $1 in a database created of file $2. All the overlapping blast hits are merged together and coverage is calculated for each fasta file in $1.\n"
# Author - Ranjit Kumar (ranjit58@gmail.com)
# Source code - 
# Usage - blast-coverage.sh FASTA1 FASTA2
#-------------------------------------------------------------------------



# check for dependencies BLAST and BEDTools (if not please include them, otherwise program will fail)

echo -e "\nAssuming BLAST and BEDTools are in PATH\n"
echo -e "The program will find all blast hits for file $1 in a database created of file $2. All the overlapping blast hits are merged together and coverage is calculated for each fasta file in $1.\n"

echo -e "Counting length of all contigs for $1 and storing them in file $1.bed\n"
my-count-fatsa.pl $1 > $1.bed

echo -e "Creating blast database of file $2\n"
formatdb -i $2 -p F -n $2

echo -e "Runnin the blast/megablast command for input file $1 against database $2. The general blast output file is named $1-$2.mb.blastout and a taubualr format file (which is used for later steps) is named $1-$2.mb.out\n"
megablast -d $2 -i $1 -F F > $1-$2.mb.blastout
megablast -d $2 -i $1 -F F -m 8 > $1-$2.mb.out

echo -e "Converting the blast output to a gff format. Output is named $1-$2.mb.gff\n"
my-blast2gff.pl $1-$2.mb.out > $1-$2.mb.gff

echo -e "Sorting the blast gff output. Output is named $1-$2.mbs.gff\n"
sortBed -i $1-$2.mb.gff > $1-$2.mbs.gff

echo -e "Calculating the coverage of blast hits for all fasta file in $1. Output is named coverage-$1-$2.bed\n"
coverageBed -a $1-$2.mbs.gff -b $1.bed > coverage-$1-$2.bed

echo -e "Merging all the overlapping blast-hits. Output is named $1-$2.mbsm.gff\n"
mergeBed -i $1-$2.mbs.gff > $1-$2.mbsm.gff

echo -e "Calculating the unique regions in $1 which are not covered by blast hits agaisnt $2 database. Output is named unique-$1-$2.gff\n"
subtractBed -a $1.bed -b $1-$2.mbsm.gff > unique-$1-$2.gff

echo -e "Program completed...\n\n"
