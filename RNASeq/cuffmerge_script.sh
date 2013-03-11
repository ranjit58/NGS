#!/bin/bash

#----cluster parameters-------
PROCESSOR=2
MEM="4G"
DURATION="08:00:00"
#------------------------------

#----PATH--------------------
#INDEX=/scratch/share/public_datasets/ngs/genomes_handbuilt/dkcrossm/ucsc.mm10/bowtie2/ucsc.mm10
FASTA=/scratch/share/public_datasets/ngs/genomes_handbuilt/dkcrossm/ucsc.mm10/bowtie2/ucsc.mm10.fa
GTF=/scratch/share/public_datasets/ngs/gtfs/mm10_patched.gtf
INPUT=cufflinks_results
OUTPUT=cuffmerge_results
#---------------------------


mkdir ${OUTPUT}
find ${INPUT} -name "transcripts.gtf" > ${OUTPUT}/assemblies.txt

COMMAND="cuffmerge -p ${PROCESSOR} -g ${GTF} -s ${FASTA} -o $OUTPUT ${OUTPUT}/assemblies.txt"
echo "$COMMAND">temp.script
cat temp.script >>cuffmerge.log
QSUB_COMMAND="qsub -cwd -S /bin/bash -N ${i}cuffM -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>cuffmerge.log
echo `${QSUB_COMMAND}`
rm temp.script
