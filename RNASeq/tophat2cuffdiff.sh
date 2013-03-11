#!/bin/bash

#----cluster parameters-------
PROCESSOR=4
MEM="4G"
DURATION="06:00:00"
#------------------------------

#----PATH--------------------
#INDEX=/scratch/share/public_datasets/ngs/genomes_handbuilt/dkcrossm/ucsc.mm10/bowtie2/ucsc.mm10
FASTA=/scratch/share/public_datasets/ngs/genomes_handbuilt/dkcrossm/ucsc.mm10/bowtie2/ucsc.mm10.fa
GTF=/scratch/share/public_datasets/ngs/gtfs/mm10_patched.gtf
INPUT=cuffmerge_results
TOPHAT=tophat_results
OUTPUT=test_results2
#---------------------------

mkdir ${OUTPUT}

#for i in GC4,T4 C8,T8-1 C8,T8-2 C16,T16-1 C16,T16-2 GC4,C8 GC4,C16 C8,C16 T4,T8-1 T4,T8-2 T4,T16-1 T4,T16-2 T8-1,T16-1 T8-1,T16-2 T8-2,T16-1 T8-2,T16-2
#for i in C8,T8-1 C8,T8-2 C16,T16-1 C16,T16-2 GC4,C8 GC4,C16 C8,C16 T4,T8-1 T4,T8-2 T4,T16-1 T4,T16-2 T8-1,T16-1 T8-1,T16-2 T8-2,T16-1 T8-2,T16-2
for i in C8,T8-1 C8,T8-2
do 
  #echo $i
  T=${i/*,/}
  C=${i/,*/}
  echo "Paired sample for comparision are ${C} and ${T}"
  COMMAND="cuffdiff -p ${PROCESSOR} -u -L ${C},${T} -b ${FASTA} -o ${OUTPUT}/${C}-${T} test/cuffcmp.combined.gtf ${TOPHAT}/${C}-1_thout/accepted_hits.bam,${TOPHAT}/${C}-2_thout/accepted_hits.bam,${TOPHAT}/${C}-3_thout/accepted_hits.bam ${TOPHAT}/${T}-1_thout/accepted_hits.bam,${TOPHAT}/${T}-2_thout/accepted_hits.bam,${TOPHAT}/${T}-3_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>cuffdiff.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N ${i}-cdiff -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>cuffdiff.log
  echo `${QSUB_COMMAND}`
  rm temp.script
  
done
