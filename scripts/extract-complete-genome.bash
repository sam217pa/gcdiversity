#!/usr/bin/env bash

awk -F'\t' '$16 == "Complete Genome" {print;}' data_raw/prokaryotes.txt > \
    data/prokaryotes-complete-genome.txt

echo "Get complete genome only from prokaryotes.txt"
