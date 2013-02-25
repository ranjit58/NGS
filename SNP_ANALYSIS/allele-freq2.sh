##FOR LOOP###


cd allele-freq-all

cut -f 1,2 A-basefreq.txt > header-4-paste

PASTE_COMMAND="paste -f header-4-paste"

for i in Q A B C D E F G
do

echo "processing ${i}..."

cut -f 5,6 ${i}-basefreq.txt > ${i}-4-paste

PASTE_COMMAND="${PASTE_COMMAND} ${i}-4-paste"

done

echo "Running command - ${PASTE_COMMAND}" 

paste ${paste-command} > all-base-freq.txt

