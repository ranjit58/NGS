#!/scratch/user/rkumar/softwares/qiime-1.5/python-2.7.1-release/bin/python

#-------------------------------------------------------------------------
# Name - pileup-fix.py    
# Desc - The program takes a pileup file and insert the missing coordinates and only works for 1 reference file (haven't considered for more than 1 fasta seq)
# Author - Ranjit Kumar (ranjit58@gmail.com) 
# Source code - https://github.com/ranjit58/NGS/blob/master/pileup-fix.py
# Usage - pileup-fix.py fatsa_file pileup pileup_fixed
#------------------------------------------------------------------------- 


import sys
import re
import Bio
from Bio import SeqIO

seq = {}
count = 1
seqid = ""
fasta_file = open(sys.argv[1],"rU")

print "Completed reading the fasta file..."

for record in SeqIO.parse(fasta_file,"fasta"):
  seqid = record.id
  for chr in record.seq:
    seq[count] = chr
    count += 1
fasta_file.close()

#for i in seq.keys():
#  print i, "\t", seq[i]

print "Processing file, please wait..."

input = open(sys.argv[2],"r")
output = open(sys.argv[3],"w")

count = 1
for line in input:
  line=line.rstrip('\n')
  tabs = re.split('\t',line)
  
  while int(tabs[1]) >  count:
    output.write( seqid + "\t" + str(count) + "\t" + str(seq[count]) + "\t0\t\t\n" )
    count += 1
    
  output.write (line + "\n")
  count += 1

print "Completed..."
