i#!/bin/bash
#$ -S /bin/bash
#$ -cwd
#$ -N gatk
#$ -l h_rt=06:00:00,s_rt=06:00:00,vf=6G
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

cd gatk
mkdir VCF-FIL
mkdir VCF2-FIL


##FOR LOOP###

for i in A B C D E F G Q
do



# Filter SNPs P1
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-R $REF \
-T VariantFiltration \
--variant $DIR_GATK/VCF/${i}_P1_EMIT_VARIANTS_ONLY.vcf \
--out $DIR_GATK/VCF-FIL/${i}_P1_EMIT_VARIANTS_ONLY_FIL.vcf \
--clusterWindowSize 10 \
--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
--filterName "HARD_TO_VALIDATE" \
--filterExpression "DP < 5 " \
--filterName "VeryLowCoverage" \
--filterExpression "QUAL < 30.0 " \
--filterName "VeryLowQual" \
--filterExpression "QUAL > 30.0 && QUAL < 50.0 " \
--filterName "LowQual" \
--filterExpression "QD < 2.0" \
--filterName "LowQD"

grep "PASS" < $DIR_GATK/VCF-FIL/${i}_P1_EMIT_VARIANTS_ONLY_FIL.vcf > $DIR_GATK/VCF-FIL/${i}_P1_EMIT_VARIANTS_ONLY_FIL_PASS.vcf


# Filter SNPs P2
java \
-Xmx4g \
-Djava.io.tmpdir=$TEMP \
-jar $GATK/GenomeAnalysisTK.jar \
-R $REF \
-T VariantFiltration \
--variant $DIR_GATK/VCF2/${i}_P2_EMIT_VARIANTS_ONLY.vcf \
--out $DIR_GATK/VCF2-FIL/${i}_P2_EMIT_VARIANTS_ONLY_FIL.vcf \
--clusterWindowSize 10 \
--filterExpression "MQ0 >= 4 && ((MQ0 / (1.0 * DP)) > 0.1)" \
--filterName "HARD_TO_VALIDATE" \
--filterExpression "DP < 5 " \
--filterName "VeryLowCoverage" \
--filterExpression "QUAL < 30.0 " \
--filterName "VeryLowQual" \
--filterExpression "QUAL > 30.0 && QUAL < 50.0 " \
--filterName "LowQual" \
--filterExpression "QD < 2.0" \
--filterName "LowQD"

grep "PASS" < $DIR_GATK/VCF2-FIL/${i}_P2_EMIT_VARIANTS_ONLY_FIL.vcf > $DIR_GATK/VCF2-FIL/${i}_P2_EMIT_VARIANTS_ONLY_FIL_PASS.vcf

done

