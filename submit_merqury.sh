#! /usr/bin/env bash

if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES> <JOBID> <REF_MT> <PACBIO_LIST> <I_LIST>'
        Submits the modified mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data"
        exit 0

elif [ $1 == "-h" ]; then

        cat << EOF

        Usage: '$0 <SPECIES> <JOBID> <REF_MT> <PACBIO_LIST> <I_LIST>'
        Runs the modified mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data
EOF

exit 0

fi


#=== Load any modules
mitoVGP=/project/ag100pest/software/modified_mitoVGP

#=== Main program
SPECIES=$1

printf "Species ID  is $1 \n"
printf "Output is $PWD \n"

sbatch $mitoVGP/run_merqury.sh $1
