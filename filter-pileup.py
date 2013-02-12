#!/usr/bin/python

#-------------------------------------------------------------------------
# Name - filter-pileup.py    
# Desc - The program filters the insertion, deletion, and few other characters from the column 5 of pileup format
# Author - Ranjit Kumar (ranjit58@gmail.com) 
# Source code - https://github.com/ranjit58/NGS/blob/master/filter-pileup.py
# Usage - filter-pileup.py input.pileup output.pileup
#------------------------------------------------------------------------- 


import sys
import re

#read input file and create an output file
input = open(sys.argv[1],"r")
output = open(sys.argv[2],"w")

print "processing, please wait..."

# go through each line of input file and remove patterns. While loops are used to filter the presence of repeated patterns

for lines in input:
  lines=lines.rstrip('\n')
  linesplit = re.split('\t',lines)
  line = linesplit[4]
  #print line

  # filter deletions
  while (re.search('(-[0-9]+[ACGTNacgtn]+)',line)):
    if re.search('(-[0-9]+)',line):
      count = re.search('([0-9]+)',line).group(1)  
      str = '(-[0-9]+[A-Za-z]{' + count + '})'
      line = re.sub(str,'',line)

  # filter insertion
  while (re.search('(\+[0-9]+[ACGTNacgtn]+)',line)):
    if re.search('(\+[0-9]+)',line):
      count = re.search('([0-9]+)',line).group(1)
      str = '(\+[0-9]+[A-Za-z]{' + count + '})'
      line = re.sub(str,'',line)
  
  # filter ^ and its next chatacter
  while (re.search('\^.{1}',line)):
    line = re.sub('\^.{1}','',line)

  # write the output file
  output.write(linesplit[0] + "\t" + linesplit[1] + "\t" + linesplit[2] + "\t" + linesplit[3] + "\t" + line + "\t" + linesplit[5]  + "\n")
  
print "Completed !",
