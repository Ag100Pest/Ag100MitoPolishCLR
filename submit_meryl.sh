#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES_ID> '
        Submits a list of illumina files to create a meryl db.
        Expects file I_list.txt to be in working SLURM_SUBMIT_DIR \n"
        exit 1
fi

if [[ ! -f I_list.txt ]]; then
	printf "Expects file I_list.txt in working dir or SLURM_SUBMIT_DIR. Missing this file. Try again."
else
	printf "Illimuna reads in $(cat I_list.txt) \n"
fi

printf "out meryl db in ${1}.k31.meryl \n"

sbatch $MERQ/_submit_build.sh 31 I_list.txt $1
