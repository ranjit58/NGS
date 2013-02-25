##FOR LOOP###

#mkdir allele-freq-all
cd allele-freq-all

for i in A B C D E F G Q
do
echo "processing ${i}..."
#../../../../softwares/samtools-dev/samtools/samtools mpileup -AB -f ../Q_REF.fa ../gatk/${i}_sorted_arg_md_realigned_mpf.bam -Q 30 -q 30 > ${i}-ABQ30q30.pileup
pileup-fix.py Q_REF.fa ${i}-ABQ30q30.pileup ${i}-ABQ30q30.pileup.fixed
filter-pileup.py ${i}-ABQ30q30.pileup.fixed ${i}-ABQ30q30.pileup.fixed.fil
refpercent-pileup.py ${i}-ABQ30q30.pileup.fixed.fil ${i}-basefreq.txt

done
