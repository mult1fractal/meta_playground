#!/usr/bin/python
import sys

#get fname from parameter
idfile=sys.argv[1]

#load ids
ids = set( x.strip() for x in open(idfile) )

#read stdid 
handle=sys.stdin  

while ids:
  #parse fastq
  idline=handle.readline()
  seq   =handle.readline()
  spacer=handle.readline()
  quals =handle.readline()
  #check
  id=idline[:-1]
  if id in ids:
    #print fastq
    sys.stdout.write( '%s%s%s%s' % ( idline, seq, spacer, quals ) )
    #update ids
    ids.remove( id )



## from: https://www.biostars.org/p/10353/