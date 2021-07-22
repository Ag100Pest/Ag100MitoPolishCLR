#! /usr/bin/env bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=CLR_mitoVGP         #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

#=== Load any modules
export PATH=$PATH:/project/ag100pest/software/modified_mitoVGP/
mitoVGP=/project/ag100pest/software/modified_mitoVGP

#=== Main program
# printf "running on species $1 with jobid $2"
SPECIES=$1 #"Pectinophora_gossypiella" # hardcoded for now
I=$2 #"Pgos5"

mkdir -p /project/ag100pest/Pgos/RawData/MT_Contig/mitoVGP
cd /project/ag100pest/Pgos/RawData/MT_Contig/mitoVGP
source activate $mitoVGP/pacbio_mitoVGP
$mitoVGP/run_mitoVGP.sh $SPECIES $I  # hardcoded for Pgos


