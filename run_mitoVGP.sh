#!/bin/bash
if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES> <JOBID>'
        Runs the modificed mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data"
        exit 0

elif [ $1 == "-h" ]; then

        cat << EOF

        Usage: '$0 <SPECIES> <JOBID>'
        Runs the modificed mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data
EOF

exit 0

fi

mitoVGP=/project/ag100pest/software/modified_mitoVGP
SPECIES=$1
J=$2
echo $SPECIES
echo $J

module load canu/1.8 #default is 2.1.1

$mitoVGP/mitoVGP -a pacbio \
	-s $SPECIES -i $J -r NC_041123.1.fasta \
	-t 30 \
	-1 PB_list.txt \
	-2 I_list.txt \
	-z 5000

