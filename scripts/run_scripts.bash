#!/usr/bin/env bash
shuf -n 100 prokaryotes.txt > exemple100.txt

touch tmp.txt

while IFS='' read -r line #|| [[ -n "$line" ]]
do
	#extrait les numéros d'accession avec ton super script
	echo "$line" | python parsing_prokaryotes.py >> tmp.txt
	# exécute la commande raa_query sur tmp.txt
	bash run_raa_query.sh tmp.txt



done < exemple100.txt

##bash run_scripts.bash

