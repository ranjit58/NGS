#!/usr/bin/python

#--------------------------------------------------------------------------
# Name - filter-pileup.py    
# Desc - The program filters the insertion, deletion, and few other characters from the column 5 of pileup format
# Author - Ranjit Kumar (ranjit58@gmail.com) 
# Source code - 



import sys
import re

#read file
input = open(sys.argv[1],"r")
output = open(sys.argv[2],"w")

for lines in input:
  lines=lines.rstrip('\n')
  linesplit = re.split('\t',lines)
  line = linesplit[4]
  #print line
  
  while (re.search('(-[0-9]+[ACGTNacgtn]+)',line)):
    #print line
    if re.search('(-[0-9]+)',line):
      count = re.search('([0-9]+)',line).group(1)  
      str = '(-[0-9]+[A-Za-z]{' + count + '})'
      line = re.sub(str,'',line)
     # print str
     # print line

  while (re.search('(\+[0-9]+[ACGTNacgtn]+)',line)):
    #print line
    if re.search('(\+[0-9]+)',line):
      count = re.search('([0-9]+)',line).group(1)
      str = '(\+[0-9]+[A-Za-z]{' + count + '})'
      line = re.sub(str,'',line)
     # print str
     # print line

  while (re.search('\^.{1}',line)):
    #print line
    line = re.sub('\^.{1}','',line)
    #print line

  output.write(linesplit[0] + "\t" + linesplit[1] + "\t" + linesplit[2] + "\t" + linesplit[3] + "\t" + line + "\t" + linesplit[5]  + "\n")
