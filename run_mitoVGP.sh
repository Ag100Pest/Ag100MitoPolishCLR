#!/bin/bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=CLR_mitoVGP         #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES> <JOBID> <REF_MT> <PACBIO_LIST> <I_LIST>'
        Runs the modificed mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data"
        exit 0

elif [ $1 == "-h" ]; then

        cat << EOF

        Usage: '$0 <SPECIES> <JOBID> <REF_MT> <PACBIO_LIST> <I_LIST>'
        Runs the modificed mitoVGP pipeline to assemble mitochondrial genomes from pacbio CRL and illumina polishing data
EOF

exit 0

fi

module load miniconda

mitoVGP=/project/ag100pest/software/modified_mitoVGP
source activate $mitoVGP/pacbio_mitoVGP

SPECIES=$1
J=$2
REF=$3
PB_LS=$4
I_LS=$5

printf "Species is $SPECIES \n"
printf "Job id is  $J \n"
printf "Reference mt genome is $REF \n"
printf "Input pacbio reads are $PB_LS \n"
printf "Input pacbio reads are $I_LS \n"
printf "Output is $OUT \n"

OUT=/project/ag100pest/$SPECIES/RawData/MT_Contig/
mkdir -p $OUT/mitoVGP

## pipeline is sensitive to canu version. throw error if not 2.1
module load canu/2.1 #default is 2.1.1

$mitoVGP/mitoVGP -a pacbio \
	-s $SPECIES -i $J -r $REF \
	-t 30 \
	-1 $PB_LS \
	-2 $I_LS \
	-z 5000 # increases sesnitivity of mummer

