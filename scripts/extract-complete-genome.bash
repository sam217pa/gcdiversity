#!/usr/bin/env bash

# Samuel, 2017-04-13

# if file does not exist, download it from NCBI ftp servers
if [[ ! -e data_raw/prokaryotes.txt ]]; then
    wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt -O \
         data_raw/prokaryotes.txt
fi

# extract only complete genomes
awk -F'\t' '$16 == "Complete Genome" {print;}' data_raw/prokaryotes.txt > \
    data/prokaryotes-complete-genome.txt && \
    printf "\nGot complete genome only from prokaryotes.txt\n\n"

# extract chromosome access number list
cat data/prokaryotes-complete-genome.txt | \
    awk -F'\t' '{print $9;}'  > data/chromosome-access-list.txt

# extract first chromosome acces list
cat data/chromosome-access-list.txt | \
    awk -F';' 'match($1, /[\/:].{10}$/) {print substr($1, RSTART + 1, RLENGTH - 3);}' > \
        data/chromosome-first-access-list.txt && \
    printf "Extracted primary chromosome accession numbers\n" && \
    wc -l data/chromosome-first-access-list.txt

# extract only secondary chromosome access number
cat data/chromosome-access-list.txt | \
    awk -F';' '$2 ~ /chromosome [(2)(linear)(II)(phage)(unnamed)]/ {print $2;}' | \
    awk 'match($2, /[\/:].{10}$/) {print substr($2, RSTART + 1, RLENGTH - 3);}' > \
        data/chromosome-secondary-access-list.txt && \
    printf "\nExtracted secondary chromosome accession numbers\n" && \
    wc -l data/chromosome-secondary-access-list.txt
