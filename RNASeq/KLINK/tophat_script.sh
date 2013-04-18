#!/bin/bash

#----cluster parameters-------
PROCESSOR=4
MEM="5.9G"
DURATION="24:00:00"
#------------------------------

#----PATH--------------------
INDEX=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189
GTF=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189_gene_exons.gff3
RAW_FASTQ=/home/rkumar/workdir/analysis/Klink/klink-rnaseq-raw
OUTPUT_FOLDER=tophat_results
MATE_PAIR_DISTANCE=100
#---------------------------

mkdir ${OUTPUT_FOLDER}


for i in H1 H2 H3 H4 H5 H6 XT1 XT2 XT3 XT4 XT5 XT6


do 
  #echo "${i}"
  COMMAND="tophat -p ${PROCESSOR} -G ${GTF} -r ${MATE_PAIR_DISTANCE} -o ${OUTPUT_FOLDER}/${i}_thout $INDEX ${RAW_FASTQ}/${i}_R1.fastq ${RAW_FASTQ}/${i}_R2.fastq"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT_FOLDER}/tophat_run.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N ${i} -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">> ${OUTPUT_FOLDER}/tophat_run.log
  echo `${QSUB_COMMAND}`
  rm temp.script
done
