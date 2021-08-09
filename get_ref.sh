#! /usr/bin/env bash

if [ -z $1 ] || [ $1 == "-h" ]; then

        printf "Usage: '$0 <NCBI MT GENOME ACCESSION ID>'
        Uses esearch and efetch of the edirect module to download fasta and genbank files for a given NCBI accession ID.
	E.g., '$0  NC_041123' \n"

exit 0

fi

module load edirect
esearch -db nucleotide -query “${1}” | \
efetch -format fasta > ref.fasta

esearch -db nucleotide -query “${1}” | \
efetch -format gb > ref.gb

