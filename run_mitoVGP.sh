#!/bin/bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=CLR_mitoVGP        #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES_ID> '
        Runs the modified mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data.
	Expects files: ref.fasta, PB_list.txt, and I_list.txt to be in working SLURM_SUBMIT_DIR \n"
        exit 0
fi

if [[ ! -f ref.fasta ]] && \
	[[ ! -f PB_list.txt ]] && \
	[[ ! -f I_list.txt ]]; then

printf "Expects files: ref.fasta, PB_list.txt, and I_list.txt to be in working SLURM_SUBMIT_DIR.
	Missing one of these."
#        cat << EOF

#        Usage: '$0 <SPECIES> <JOBID> <REF_MT> <PACBIO_LIST> <I_LIST>'
#        Runs the modificed mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data
#EOF

exit 0

fi

module load miniconda

mitoVGP=/project/ag100pest/software/modified_mitoVGP
source activate $mitoVGP/pacbio_mitoVGP

printf "Species ID is $1 \n"
printf "Reference mt genome is $(head -n 1 ref.fasta) \n"
printf "Input pacbio reads are $(cat PB_list.txt) \n"
printf "Input pacbio reads are $(cat I_list.txt) \n"

if [[ ! -z $SLURM_SUBMIT_DIR ]]; then
printf "working directory =  $PWD "
else
printf "working directory =  $SLURM_SUBMIT_DIR "
fi


## pipeline is sensitive to canu version. throw error if not 2.1
module load canu/2.1 #default is 2.1.1

$mitoVGP/mitoVGP -a pacbio \
	-i $1 -r ref.fasta \
	-t 30 \
	-1 PB_list.txt \
	-2 I_list.txt \
	-z 5000 # increases sesnitivity of mummer

