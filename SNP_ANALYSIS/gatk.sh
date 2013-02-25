#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N gatk
#$ -l h_rt=24:00:00,s_rt=24:00:00,vf=6G
#$ -M rkumar@uab.edu
#$ -m eas


# PIPELINE TO INPUT BAM FILES FOR ALL SAMPLES AND OUTPUT FILTERED GATK SNPS AND INDELS
#INFO : PATH for many executables are already setup like $GATK and $PICARD in bashrc.
#INFO : $TEMP is already defined in bashrc

#---VARIABLES AND PATH -------------------------#



REF=/home/rkumar/workdir/analysis/vikram/newanalysis/Q_REF.fa
DIR_FASTA=/home/rkumar/workdir/analysis/vikram/raw_data
DIR_BAM=/home/rkumar/workdir/analysis/vikram/newanalysis/bwa_align
DIR_GATK=/home/rkumar/workdir/analysis/vikram/newanalysis/gatk

mkdir gatk
cd gatk
mkdir VCF
mkdir VCF2
mkdir INDELS
mkdir INDELS2


samtools faidx $REF

# Create sequence dictionary
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $PICARD/CreateSequenceDictionary.jar \
REFERENCE=$REF \
OUTPUT=$REF.dict


##FOR LOOP###

for i in A B C D E F G Q
do



#--- for AddOrReplaceReadGroups picard tools ---#
SEQMACHINE=BGI_MACHINE
STRAIN=$i  #(overwritten in for loop)
RGPL=ILLUMINA
RGPU=$SEQMACHINE
RGSM=$STRAIN #(overridden in for loop)
RGID=$STRAIN:$SEQMACHINE
#-----------------------------------------------


# Add or replace group
java \
-Xmx2g \
-Djava.io.tmpdir=$TEMP \
-jar $PICARD/AddOrReplaceReadGroups.jar I=$DIR_BAM/${i}_sorted.bam O=$DIR_GATK/${i}_sorted_arg.bam TMP_DIR=$TEMP SORT_ORDER=coordinate RGID=STRAIN:SEQMACHINE RGLB=unknown RGPL=$RGPL RGPU=$RGPU RGSM=$RGSM CREATE_INDEX=True VALIDATION_STRINGENCY=SILENT


# Mark Duplicates
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $PICARD/MarkDuplicates.jar CREATE_INDEX=True TMP_DIR=$TEMP MAX_RECORDS_IN_RAM=1000000 INPUT= $DIR_GATK/${i}_sorted_arg.bam OUTPUT=$DIR_GATK/${i}_sorted_arg_md.bam METRICS_FILE= $DIR_GATK/${i}_sorted_arg_md_metrics.txt VALIDATION_STRINGENCY=LENIENT ASSUME_SORTED=False

# Create table for local realignment around indels
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-T RealignerTargetCreator \
-R $REF \
-o $DIR_GATK/${i}_sorted_arg_md.intervals \
-I $DIR_GATK/${i}_sorted_arg_md.bam


# Perform local realignment around indels
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-T IndelRealigner \
-I $DIR_GATK/${i}_sorted_arg_md.bam \
-R $REF \
-o $DIR_GATK/${i}_sorted_arg_md_realigned.bam \
-targetIntervals $DIR_GATK/${i}_sorted_arg_md.intervals

# Fix Mate pair information (which may have become inconsistent due to local relaignment around indels
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $PICARD/FixMateInformation.jar \
INPUT=$DIR_GATK/${i}_sorted_arg_md_realigned.bam \
OUTPUT=$DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
SO=coordinate \
VALIDATION_STRINGENCY=LENIENT \
CREATE_INDEX=true


# Call SNPs
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 1 \
-o $DIR_GATK/VCF/${i}_P1_EMIT_VARIANTS_ONLY.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_VARIANTS_ONLY


java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 1 \
-o $DIR_GATK/VCF/${i}_P1_EMIT_ALL_CONFIDENT_SITES.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_ALL_CONFIDENT_SITES

java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 1 \
-o $DIR_GATK/VCF/${i}_P1_EMIT_ALL_SITES.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_ALL_SITES




# Call SNPs
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 2 \
-o $DIR_GATK/VCF2/${i}_P2_EMIT_VARIANTS_ONLY.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_VARIANTS_ONLY


java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 2 \
-o $DIR_GATK/VCF2/${i}_P2_EMIT_ALL_CONFIDENT_SITES.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_ALL_CONFIDENT_SITES


java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm SNP \
-ploidy 2 \
-o $DIR_GATK/VCF2/${i}_P2_EMIT_ALL_SITES.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_ALL_SITES




# Call INDELs P1
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm INDEL \
-ploidy 1 \
-o $DIR_GATK/INDELS/${i}_P1_indels.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_VARIANTS_ONLY

# Call INDELs P2
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-l INFO \
-T UnifiedGenotyper \
-R $REF \
-I $DIR_GATK/${i}_sorted_arg_md_realigned_mpf.bam \
-stand_call_conf 50.0 \
-stand_emit_conf 10.0 \
-dcov 1000 \
-glm INDEL \
-ploidy 2 \
-o $DIR_GATK/INDELS2/${i}_P2_indels.vcf \
-A DepthOfCoverage \
-A AlleleBalance \
--output_mode EMIT_VARIANTS_ONLY


done

