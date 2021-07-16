#! /usr/bin/env bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=CLR_mitoVGP         #<= name your job
#SBATCH --output=./std/R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=./std/R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

#=== Load any modules
export PATH=$PATH:/project/ag100pest/software/modified_mitoVGP/
module load conda
mitoVGP=/project/ag100pest/software/modified_mitoVGP/

#=== Main program
cd /project/ag100pest/Pgos/RawData/MT_Contig/mitoVGP # hardcoded for Pgos
source activate $mitoVGP/pacbio_mitoVGP
./run_mitoVGP.sh # hardcoded for Pgos


