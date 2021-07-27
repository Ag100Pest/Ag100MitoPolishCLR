#!/bin/bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=mitofinder        #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

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

if [[ ! -z $2 ]]; then
        printf "\n=== Output will be in dir  $2 \n"
fi

mitoVGP=/project/ag100pest/software/modified_mitoVGP

$mitoVGP/mitofinder/MitoFinder_container/MitoFinder_v1.4 \
-j $2 \
-a $1 \
-r ref.gb -o 5 -p 8

