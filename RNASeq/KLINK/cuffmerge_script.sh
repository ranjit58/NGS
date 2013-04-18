#!/bin/bash

#----cluster parameters-------
PROCESSOR=4
MEM="4G"
DURATION="12:00:00"
#------------------------------

#----PATH--------------------
FASTA=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189.fa
GTF=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189_gene_exons.gff3
INPUT=cufflinks_results
OUTPUT=cuffmerge_results
#---------------------------


mkdir ${OUTPUT}
find ${INPUT} -name "transcripts.gtf" > ${OUTPUT}/assemblies.txt

COMMAND="cuffmerge -p ${PROCESSOR} -g ${GTF} -s ${FASTA} -o $OUTPUT ${OUTPUT}/assemblies.txt"
echo "$COMMAND">temp.script
cat temp.script >>${OUTPUT}/cuffmerge.log
QSUB_COMMAND="qsub -cwd -S /bin/bash -N ${i}cuffM -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cuffmerge.log
echo `${QSUB_COMMAND}`
rm temp.script
