#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

## USAGE:
##
##    ./get-accession-number.bash "line from prokaryotes.txt"
##
## DESCRIPTION:
##
##    This script returns the different genbank accession numbers in a line from
##    prokaryotes-complete-genome.txt and print them to STDOUT.
##
##    It is useful to download complete genome with raa_query. Numbers are
##    written to a file read by raa_query to select sequences by accession
##    number.
##
## OPTIONS:
##
##   --help: Display this help message
##
## AUTHOR:
##
##   Samuel Barreto, (2017-04-26)
##

usage() { grep "^##" "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage
if [ $# -eq 0 ]; then > /dev/null && usage; fi

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warn()    { echo "[WARN]    $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

# Remove temporary files
# Restart services
# ...
cleanup() { echo "" ; }

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    echo "$1" | \
        awk -F'\t' '{print $9;}'|\
        awk -F';' 'match($1, /[\/:].{10}$/) {print substr($1, RSTART + 1, RLENGTH - 3);}'

    echo "$1" | \
        awk -F'\t' '{print $9;}'| \
        awk -F';' '$2 ~ /chromosome [(2)(linear)(II)(phage)(unnamed)]/ {print $2;}' | \
        awk 'match($2, /[\/:].{10}$/) {print substr($2, RSTART + 1, RLENGTH - 3);}'

    echo "$1" | \
        awk -F'\t' '{print $9;}'| \
        awk -F';' '$3 ~ /chromosome/ {print $3;}' | \
        awk 'match($2, /[\/:].{10}$/) {print substr($2, RSTART + 1, RLENGTH - 3);}'


fi
