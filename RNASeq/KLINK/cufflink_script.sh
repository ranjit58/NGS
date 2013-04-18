#!/bin/bash

#----cluster parameters-------
PROCESSOR=4
MEM="4G"
DURATION="24:00:00"
#------------------------------

#----PATH--------------------
#INDEX=/scratch/share/public_datasets/ngs/genomes_handbuilt/dkcrossm/ucsc.mm10/bowtie2/ucsc.mm10
FASTA=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189.fa
GTF=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189_gene_exons.gff3
INPUT=tophat_results
OUTPUT=cufflinks_results
#---------------------------

mkdir ${OUTPUT}

for i in H1 H3 H4 H5 H6 XT1 XT2 XT3 XT4 XT5 XT6

do 
  #echo "${i}"
  COMMAND="cufflinks -p ${PROCESSOR} --upper-quartile-norm -L ${i} -b ${FASTA} -G ${GTF} -o ${OUTPUT}/${i}_clout ${INPUT}/${i}_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT}/cufflinks_run.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N ${i}-cuff -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cufflinks_run.log
  echo `${QSUB_COMMAND}`
  rm temp.script
done
