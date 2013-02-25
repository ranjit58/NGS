#!/usr/bin/python

import sys
import re

# read file in pileup format
input = open(sys.argv[1],"r")
outf10 = open("f10.txt","w")
outf20 = open("f20.txt","w")
outf30 = open("f30.txt","w")
outf40 = open("f40.txt","w")
outf50 = open("f50.txt","w")
outf60 = open("f60.txt","w")
outf70 = open("f70.txt","w")
outf80 = open("f80.txt","w")
outf90 = open("f90.txt","w")
outf100 = open("f100.txt","w")


print "processing, please wait..."

min_depth = 20

for lines in input:
  lines=lines.rstrip('\n')
  tabs = re.split('\t',lines)

  if (tabs[0] != "ref" and int(tabs[2]) >= min_depth and int(tabs[4]) >= min_depth and int(tabs[6]) >= min_depth and int(tabs[8]) >= min_depth and int(tabs[10]) >= min_depth and int(tabs[12]) >= min_depth and int(tabs[14]) >= min_depth and int(tabs[16]) >= min_depth) :
  
    listoffreq = [3,5,7,9,11,13,15,17]
    listofdepth = [2,4,6,8,10,12,14,16]
    listforstats = []
   
    for i in listofdepth:
      if int(tabs[i]) != 0:
        temp = i + 1
        listforstats.append([(float(tabs[temp]))])

    min_value = min(listforstats)
    max_value = max(listforstats)
    range_value = max_value[0] - min_value[0]
    
    if range_value <= 0.10:
      outf10.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.10 and range_value <= 0.20:
      outf20.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.20 and range_value <= 0.30:
      outf30.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.30 and range_value <= 0.40:
      outf40.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.40 and range_value <= 0.50:
      outf50.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.50 and range_value <= 0.60:
      outf60.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.60 and range_value <= 0.70:
      outf70.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.70 and range_value <= 0.80:
      outf80.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.80 and range_value <= 0.90:
      outf90.write(lines + "\t" + str(range_value) + "\n")
    if range_value > 0.90:
      outf100.write(lines + "\t" + str(range_value) + "\n")
    

    #print lines
    #for i in listforstats:
    #  print i,"\t",
    #print ""
    #print range_value, "----", max_value, "----", min_value
