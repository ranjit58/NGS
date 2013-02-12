#!/usr/bin/python

#-------------------------------------------------------------------------
# Name - basefreq-pileup.py
# Desc - The program caculate the base frequency of ATGCN for each base position from the column 5 of pileup format
# Author - Ranjit Kumar (ranjit58@gmail.com)
# Source code - https://github.com/ranjit58/NGS/blob/master/basefreq-pileup.py
#-------------------------------------------------------------------------


import sys
import re

# read file in pileup format
input_pileup = open(sys.argv[1],"r")
output = open(sys.argv[2],"w")

print "processing, please wait..."

output.write("ref\tcoord\tbase\tdepth\tA\tG\tC\tT\tN\tDel\n")

for line in input_pileup:
  #print line
  line=line.rstrip('\n')
  linesplit = re.split('\t',line)

  # store basic dataset in some variables
  ref = linesplit[0]
  coordinate =  linesplit[1]
  base =  linesplit[2]
  depth =  linesplit[3]

  # initiate all variables as zero
  count_base = 0
  count_A = 0
  count_T = 0
  count_G = 0
  count_C = 0
  count_N = 0
  #count_ins = 0
  count_del = 0
  #count_amb = 0

  #iterate over column five of pileup format and count ATGCN. Count . and , as base count and latter assign  it to ATGCN.
  for c in linesplit[4]:
    if c == '.' or c == ',':
      count_base += 1
    elif c.upper() == 'A':
      count_A += 1
    elif c.upper() == 'T':
      count_T += 1
    elif c.upper() == 'G':
      count_G += 1
    elif c.upper() == 'C':
      count_C += 1
    elif c.upper() == 'N':
      count_N += 1
    elif c == '*':
      count_del += 1

  #assign count_base to anybase ATGC
  if base.upper() == 'A':
    count_A += count_base
  if base.upper() == 'T':
    count_T += count_base
  if base.upper() == 'G':
    count_G += count_base
  if base.upper() == 'C':
    count_C += count_base
  if base.upper() == 'N':
    count_N += count_base

  output.write(ref + "\t" + coordinate + "\t" + base + "\t" + depth + "\t" + str(count_A) + "\t" + str(count_G) + "\t" + str(count_C) + "\t" + str(count_T) + "\t" + str(count_N) + "\t" + str(count_del) + "\n")
  
print "Completed !"

 
  
