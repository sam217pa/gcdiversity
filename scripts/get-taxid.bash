#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

## USAGE:
##
##   ./get-taxid.bash "line"
##
## DESCRIPTION:
##
##   This script extract TaxID from a line of prokaryotes_complete_genome.txt.
##   This is useful for naming files downstream.
##
## EXAMPLES:
##
##    ./get-taxid.bash $(head -n 2 data/prokaryotes-complete-genome.txt | tail -n +2)
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
# if [ $# -eq 0 ]; then > /dev/null && usage; fi

readonly LOG_FILE="/tmp/$(basename "$0").log"
info()    { echo "[INFO]    $@" | tee -a "$LOG_FILE" >&2 ; }
warning() { echo "[WARNING] $@" | tee -a "$LOG_FILE" >&2 ; }
error()   { echo "[ERROR]   $@" | tee -a "$LOG_FILE" >&2 ; }
fatal()   { echo "[FATAL]   $@" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

cleanup() { info "Cleanup" ; }

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
    trap cleanup EXIT

    gawk -F'\t' '{print $2;}' $1
fi
