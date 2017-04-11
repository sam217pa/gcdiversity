
# Exemple de script pour extraire les séquences

###################################################
echo -n "Fichier: "
echo $1
\rm $1.*

raa_query <<!
7
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
!

#set num_acc = `cat $1 |wc -l`
#set num_seq = `grep ">" $1.genome |wc -l`

#echo "$num_acc Accession number, $num_seq sequences extracted"


#if($num_acc != $num_seq) then
#	echo "WARNING: incorrect sequence number"
#endif



#\rm $1.cds $1.genome
