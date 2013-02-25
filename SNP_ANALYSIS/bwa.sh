#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N bwa
#$ -pe smp 4
#$ -l h_rt=24:00:00,s_rt=24:00:00,vf=4G
#$ -M rkumar@uab.edu
#$ -m eas

REF=/home/rkumar/workdir/analysis/vikram/newanalysis/Q_REF.fa
DIR=/home/rkumar/workdir/analysis/vikram/raw_data
mkdir bwa_align
cd bwa_align

bwa index $REF
for i in A B C D E F G Q

do
  bwa aln -t 4 -I $REF $DIR/${i}_1.fastq > ${i}_1.sai
  bwa aln -t 4 -I $REF $DIR/${i}_2.fastq > ${i}_2.sai
  bwa sampe -P $REF ${i}_1.sai ${i}_2.sai $DIR/${i}_1.fastq $DIR/${i}_2.fastq > ${i}.sam
  samtools view -bS ${i}.sam > ${i}.bam
  samtools sort ${i}.bam ${i}_sorted
  samtools index ${i}_sorted.bam
  samtools flagstat ${i}_sorted.bam > ${i}_flagstat.txt
done
