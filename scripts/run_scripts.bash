#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'


## USAGE:
##
##   ./run_scripts.bash
##
## DESCRIPTION:
##
##   This file download the prokaryotes.txt file from NCBI genome reports
##   servers and extract the chromosome accession list of complete genomes. As
##   of 2017-04-26, there are about 7400 complete genomes available on genbank.
##
##   It then extract the TAXID of each line and download the corresponding
##   genome sequences and coding sequences for each accession number using the
##   raa_query utility. This utility uses the ACNUC query language described in
##   details in http://seqinr.r-forge.r-project.org/seqinr_3_1-5.pdf.
##
## OPTIONS:
##
##   --help: Display this help message
##
## AUTHOR:
##
##   Samuel Barreto, 2017-04-26
##   Mokhtaria Kalfaoui, 2017-04-26
##

usage() { grep "^##" "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage
# if [ $# -eq 0 ]; then > /dev/null && usage; fi

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warn()    { echo "[WARN]    $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() {
    unset TAXID;
    unset n;
    warn "Cleaned up variables"; }

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    # if file does not exist, download it from NCBI ftp servers
    if [[ ! -e data_raw/prokaryotes.txt ]]; then
        wget ftp://ftp.ncbi.nlm.nih.gov/genomes/GENOME_REPORTS/prokaryotes.txt -O \
             data_raw/prokaryotes.txt
    fi



    # extract only complete genomes
    complete_genome_only=data/prokaryotes-complete-genome.txt

    if [[ ! -e "$complete_genome_only" ]]; then
        awk -F'\t' '$16 == "Complete Genome" {print;}' data_raw/prokaryotes.txt > \
            "$complete_genome_only" && \
            printf "\nGot complete genome only from prokaryotes.txt\n\n"
    fi

    n_genome=0
    N_genome="$(wc -l $complete_genome_only | awk '{print $1}')"

    while IFS='' read -r LINE
    do
        n_genome=$(($n_genome + 1));
        info "$n_genome / $N_genome"

        # TaxID extraction
        TAXID=$(echo "$LINE" | gawk -F'\t' '{print $2;}')

        # extract access number
        scripts/get-accession-number.bash "$LINE" > data/"$TAXID".access

        # download complete genome
        if [[ ! -e data/"$TAXID".access.genome ]]; then
            scripts/run_raa_query.bash data/"$TAXID".access >& /dev/null
        else
            warn "genome already downloaded"
        fi

    done < "$complete_genome_only"

fi
