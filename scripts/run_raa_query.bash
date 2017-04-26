#!/usr/bin/env bash

## In order, this file
##
## - chose genbank as the database to query (1)
## - select sequences (by accession number)
## - file accession number containing is $1, first argument to script.
## - extract sequences
## - contained in LIST1
## - change default format
## - to fasta (2)
## - to file named $1.genome
## - then select sequences
## - in LIST1, restricted to CDS
## - extract sequences
## - to fasta
## - in file named $1.cds
## - and stop

raa_query <<EOF
1
sel
fa=$1
ex
list1
y
2
$1.genome
1
sel
list1 et t=cds
ex
list2
y
2
$1.cds
1
stop
EOF
