#!/usr/bin/python

#-------------------------------------------------------------------------
# Name - refpercent-pileup.py
# Desc - The program caculate the base frequency of ATGCN for each base position from the column 5 of pileup format
# Author - Ranjit Kumar (ranjit58@gmail.com)
# Source code - https://github.com/ranjit58/NGS/blob/master/refpercent-pileup.py
# Usage - refpercent-pileup.py input_pileup output
#-------------------------------------------------------------------------

from __future__ import division
import sys
import re

# read file in pileup format
input_pileup = open(sys.argv[1],"r")
output = open(sys.argv[2],"w")

print "processing, please wait..."

output.write("ref\tcoord\tbase\tdepth\tbasecount\tbasefreq\tA\tG\tC\tT\tN\tDel\n")

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

  #calculate frequency
  freq_base = 0
  freq_A = 0
  freq_T = 0
  freq_G = 0
  freq_C = 0
  freq_N = 0
  freq_del = 0
  
  # count total base
  total = count_base + count_A + count_T + count_G + count_C + count_N
  
  #calculate freq and check for division by zero
  if total >0:
    if count_base != 0: freq_base = round ( count_base / total, 2)
    if count_A != 0: freq_A = round ( count_A / total, 2)
    if count_T != 0: freq_T = round ( count_T / total, 2)
    if count_G != 0: freq_G = round ( count_G / total, 2)
    if count_C != 0: freq_C = round ( count_C / total, 2)
    if count_N != 0: freq_N = round ( count_N / total, 2)
    if count_del != 0: freq_del = round ( count_del / total, 2)

  #assign freq_base to anybase ATGC
  if base.upper() == 'A':
    freq_A += freq_base
  if base.upper() == 'T':
    freq_T += freq_base
  if base.upper() == 'G':
    freq_G += freq_base
  if base.upper() == 'C':
    freq_C += freq_base
  if base.upper() == 'N':
    freq_N += freq_base

  output.write(ref + "\t" + coordinate + "\t" + base + "\t" + depth + "\t" + str(total) + "\t" + str(freq_base) + "\t" + str(freq_A) + "\t" + str(freq_G) + "\t" + str(freq_C) + "\t" + str(freq_T) + "\t" + str(freq_N) + "\t" + str(freq_del) + "\n")
print "Completed !"

 
  
