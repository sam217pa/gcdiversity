#extraire les accessions des BDD

raa_query <<!
23
sel
sp=archaea
in/lpt
list1
ac

stop
!
mv query.out data/query-archaea.out



raa_query <<!
22
sel
sp=archaea
in/lpt
list1
ACC

stop
!
mv query.out data/bacteria-archaea.out
