#!/usr/bin/python

# The program will take any number of files and merge them based on a common column. Please change the variable "common_column" as per your need.
# usage : merge_files.py file1 file2 file3 file4 (as many input file as you want)
# the program will produce a output "merged_files.txt"

import re
import sys

common_column = 2

dict = {}
tmp = 0
# list sys.argv[2] holds all the commandline arguments
# the code reads all the input files and create a merged dictionary of coordinates
for i in range(1,len(sys.argv)):
  print "reading file", sys.argv[i]
  input = open(sys.argv[i],"r")

  for line in input:
    if re.match('##|#',line):
      tmp = 0
    else:
      line=line.rstrip('\n')
      linesplit = re.split('\t',line)
      dict[linesplit[1]] = ""
  input.close()


# each file is individually read to create a temporary dictionary
# the merged dictionary is search for each temp dictionary  again and output is stored/updated as the value of merged dictionary key

for i in range(1,len(sys.argv)):
  print "reading file", sys.argv[i]
  input = open(sys.argv[i],"r")
  temp_dict = {}
  for line in input:
    if re.match('##|#',line):
      tmp = 0
    else:
      line=line.rstrip('\n')
      linesplit = re.split('\t',line)
      temp_dict[linesplit[1]] = line
  input.close()
  
  for i in dict.keys():
    if temp_dict.has_key(i):
      #dict[i] = dict[i] + "@1@" + temp_dict[i]
      dict[i] = dict[i] + "\t1"

    else:
      #dict[i] = dict[i] + "@0@"
      dict[i] = dict[i] + "\t0"
  input.close()

output = open("merged.vcf","w")
# write header
header = ""
for i in range(1,len(sys.argv)):
  header = header + "\t" + str(sys.argv[i] )

output.write("Coordinate" + header +"\n")

for i in sorted(dict.keys()):
  output.write( str(i) + "\t" + str(dict[str(i)]) + "\n")
#  tmp = 0
