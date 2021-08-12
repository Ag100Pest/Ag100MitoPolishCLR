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
WD=/project/ag100pest/$SPECIES/MT_Contig

printf "Species is $1 \n"
printf "Species ID is  $2 \n"
printf "Output is $WD \n"
cd $WD

### make some or statements here so that these things can be supplied explicitly as arguments too. 
if [[ ! -f ref.fasta ]]; then
        printf "missing ref.fasta in working dir. Expects file named ref.fasta"
        exit 1
fi

if [[ ! -f PB_list.txt ]]; then
        printf "missing PB_list.txt in working dir. Expects file named PB_list.txt"
        exit 1
fi

if [[ ! -f I_list.txt ]]; then
        printf "missing I_list.txt in working dir. Expects file named I_list.txt"
        exit 1
fi


sbatch $mitoVGP/run_mitoVGP.sh $2

## make meryl db for qv
mkdir -p $WD/qv
ln -s $WD/I_list.txt $WD/qv/
sh  $mitoVGP/submit_meryl.sh $2
