#!/usr/bin/python

import sys
import re

# read file in pileup format
input_pileup = open(sys.argv[1],"r")

print 'ref\tcoord\tbase\tdepth\tA\tG\tC\tT\tN'

for line in input_pileup:
  #print line
  line=line.rstrip('\n')
  linesplit = re.split('\t',line)

  # store basic dataset in some variables
  ref = linesplit[0]
  coordinate =  linesplit[1]
  base =  linesplit[2]
  depth =  linesplit[3]
  print ref,"\t",coordinate,"\t",base,"\t",depth,"\t",

  # initiate all count as zero
  count_base = 0
  count_A = 0
  count_T = 0
  count_G = 0
  count_C = 0
  count_N = 0
  count_ins = 0
  count_del = 0
  count_amb = 0

  #iterate over column five of pileup format (which store ATGC and base count)
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

  print count_A,"\t",count_G,"\t",count_C,"\t",count_T,"\t",count_N

 
  
