#! /usr/bin/env bash


#=== Load any modules
mitoVGP=/project/ag100pest/software/modified_mitoVGP

#=== Main program
if [ -z $1 ]; then

        printf "Usage: '$0 <fname>.fasta  <jobid>'
        Runs the modified mitofinder annotation pipeline to circularize and annotate mitochondrial genomes.
        Expects ref.gb in WD \n"

        exit 1
fi

if [[ ! -f ref.gb ]]; then
        printf "missing ref.gb in working dir. Expects file named ref.fasta"
        exit 1
else
printf "Reference mt genome is $(head -n 1 ref.gb) \n"
fi

if [[ ! -z $SLURM_SUBMIT_DIR ]]; then
        printf "=== working directory =  $PWD "
else
        printf "=== working directory =  $SLURM_SUBMIT_DIR "
fi

if [[ -z $2 ]]; then
        printf "\n=== Output will be in dir  $2 \n"
fi

printf "\n=== annotating $1 \n"

sbatch $mitoVGP/run_MitoFinder_annt.sh $1 $2
