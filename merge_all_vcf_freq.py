#!/usr/bin/python

# The program will take any number of vcf files and merge them based on similar coordintes. Each input file become a column  and each row shows if a coordinate is present in that column or not
# usage : program.py vcf1 vcf2 vcf3 vcf4 (as many input file as you want)
# the program will produce a output "merged.vcf"

import re
import sys

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
      #print re.search('ABH(om|et)=(.{4})',temp_dict[i]).group(2)
      dict[i] = dict[i]  + "\t" + re.search('ABH(om|et)=(.{4})',temp_dict[i]).group(2)
     # dict[i] = dict[i] + "\t1"

    else:
      #dict[i] = dict[i] + "@0@"
      dict[i] = dict[i] + "\t"
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
