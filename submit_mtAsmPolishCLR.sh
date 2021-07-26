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
I=$2
I_LS=$3
WD=/project/ag100pest/$SPECIES/MT_Contig

printf "Species is $SPECIES \n"
printf "Job id is  $I \n"

printf "Input illumina polish reads are $I_LS \n"
printf "Output is $WD \n"

cd $WD
sbatch $mitoVGP/run_mitoVGP.sh $I $REF $PB_LS $I_LS

