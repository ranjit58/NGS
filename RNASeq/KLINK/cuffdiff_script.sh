#!/bin/bash

#----cluster parameters-------
PROCESSOR=4
MEM="4G"
DURATION="12:00:00"
#------------------------------

#----PATH--------------------
FASTA=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189.fa
GTF=/scratch/user/rkumar/analysis/Klink/rnaseq_analysis/genome/Gmax_189_gene_exons.gff3
INPUT=cuffmerge_results
TOPHAT=tophat_results
OUTPUT=cuffdiff_results
#---------------------------

mkdir ${OUTPUT}

#-------------------------

  COMMAND="cuffdiff -p ${PROCESSOR} -N -u -L H123,XT123 -b ${FASTA} -o ${OUTPUT}/H123-XT123 ${INPUT}/merged.gtf ${TOPHAT}/H1_thout/accepted_hits.bam,${TOPHAT}/H2_thout/accepted_hits.bam,${TOPHAT}/H3_thout/accepted_hits.bam ${TOPHAT}/XT1_thout/accepted_hits.bam,${TOPHAT}/XT2_thout/accepted_hits.bam,${TOPHAT}/XT3_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT}/cuffdiff.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N H123-XT123 -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cuffdiff.log
  echo `${QSUB_COMMAND}`
  rm temp.script
 
#-----------------------

 COMMAND="cuffdiff -p ${PROCESSOR} -N -u -L H456,XT456 -b ${FASTA} -o ${OUTPUT}/H456-XT456 ${INPUT}/merged.gtf ${TOPHAT}/H4_thout/accepted_hits.bam,${TOPHAT}/H5_thout/accepted_hits.bam,${TOPHAT}/H6_thout/accepted_hits.bam ${TOPHAT}/XT4_thout/accepted_hits.bam,${TOPHAT}/XT5_thout/accepted_hits.bam,${TOPHAT}/XT6_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT}/cuffdiff.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N H456-XT456 -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cuffdiff.log
  echo `${QSUB_COMMAND}`
  rm temp.script

#----------------------
 COMMAND="cuffdiff -p ${PROCESSOR} -N -u -L XT123,XT456 -b ${FASTA} -o ${OUTPUT}/XT123-XT456 ${INPUT}/merged.gtf ${TOPHAT}/XT1_thout/accepted_hits.bam,${TOPHAT}/XT2_thout/accepted_hits.bam,${TOPHAT}/XT3_thout/accepted_hits.bam ${TOPHAT}/XT4_thout/accepted_hits.bam,${TOPHAT}/XT5_thout/accepted_hits.bam,${TOPHAT}/XT6_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT}/cuffdiff.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N XT123-XT456 -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cuffdiff.log
  echo `${QSUB_COMMAND}`
  rm temp.script

#---------------------

 COMMAND="cuffdiff -p ${PROCESSOR} -N -u -L H123,H456 -b ${FASTA} -o ${OUTPUT}/H123-H456 ${INPUT}/merged.gtf ${TOPHAT}/H1_thout/accepted_hits.bam,${TOPHAT}/H2_thout/accepted_hits.bam,${TOPHAT}/H3_thout/accepted_hits.bam ${TOPHAT}/H4_thout/accepted_hits.bam,${TOPHAT}/H5_thout/accepted_hits.bam,${TOPHAT}/H6_thout/accepted_hits.bam"
  echo "$COMMAND">temp.script
  cat temp.script >>${OUTPUT}/cuffdiff.log
  QSUB_COMMAND="qsub -cwd -S /bin/bash -N H123-H456 -pe smp ${PROCESSOR} -l h_rt=${DURATION},s_rt=${DURATION},vf=${MEM} -m eas -M ${USER}@uab.edu temp.script"
  echo -e "\nSubmitting job --> \"${QSUB_COMMAND}\"\n\n\n">>${OUTPUT}/cuffdiff.log
  echo `${QSUB_COMMAND}`
  rm temp.script
 
