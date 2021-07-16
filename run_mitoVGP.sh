#!/bin/bash

mitoVGP=/project/ag100pest/software/modified_mitoVGP

module load canu/1.8 #default is 2.1.1

$mitoVGP/mitoVGP -a pacbio \
	-s Pectinophora_gossypiella -i Pgos -r NC_041123.1.fasta \
	-t 30 \
	-1 PB_list.txt \
	-2 I_list.txt \
	-z 5000

