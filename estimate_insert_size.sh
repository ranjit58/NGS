#!/bin/sh

#-------------------------------------------------------------------------
# Name - estimate_insert_size.sh
# Desc - The program predict inset size for a given sample, taking first 5M reads from fwd and rev fastq files. It uses BWA for alignment and then PICARD tool for insert size estimation
# Author - Ranjit Kumar (ranjit58@gmail.com)
# Source code - https://github.com/ranjit58/NGS/blob/master/estimate_insert_size.sh
#-------------------------------------------------------------------------


REF='Mus_musculus.GRCm38.70.cdna.all.fa'
FASTQ_FWD='../raw_data/GC4-1-s7-1.fastq'
FASTQ_REV='../raw_data/GC4-1-s7-2.fastq'
NUM=20000000
RESULT_DIR="EIS"

#mkdir ${RESULT_DIR}

#bwa index $REF

#head -${NUM} ${FASTQ_FWD} > ${RESULT_DIR}/TEMP1.fastq
#head -${NUM} ${FASTQ_REV} > ${RESULT_DIR}/TEMP2.fastq

bwa aln -I $REF ${RESULT_DIR}/TEMP1.fastq > ${RESULT_DIR}/TEMP1.sai
bwa aln -I $REF ${RESULT_DIR}/TEMP2.fastq > ${RESULT_DIR}/TEMP2.sai
bwa sampe $REF ${RESULT_DIR}/TEMP1.sai ${RESULT_DIR}/TEMP2.sai ${RESULT_DIR}/TEMP1.fastq ${RESULT_DIR}/TEMP2.fastq > ${RESULT_DIR}/TEMP.sam
samtools view -bS ${RESULT_DIR}/TEMP.sam > ${RESULT_DIR}/TEMP.bam
#samtools sort ${RESULT_DIR}/TEMP.bam ${RESULT_DIR}/TEMP_sorted
#samtools index ${RESULT_DIR}/TEMP_sorted.bam
#samtools flagstat ${RESULT_DIR}/TEMP_sorted.bam > ${RESULT_DIR}/TEMP_flagstat.txt

