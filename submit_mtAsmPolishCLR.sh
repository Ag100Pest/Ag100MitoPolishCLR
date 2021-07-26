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
REF=$3
PB_LS=$4
I_LS=$5
WD=/project/ag100pest/$SPECIES/RawData/MT_Contig

printf "Species is $SPECIES \n"
printf "Job id is  $I \n"
printf "Reference mt genome is $REF \n"
printf "Input pacbio reads are $PB_LS \n"
printf "Input pacbio reads are $I_LS \n"
printf "Output is $OUT \n"

cD $WD
sbatch $mitoVGP/run_mitoVGP.sh $I $REF $PB_LS $I_LS

#==== Prep for eval  with merqury
#module load merqury/1.1
#module load meryl/1.0

MERQ=/project/ag100pest/software/merqury
cd $WD/qv
printf "out meryl db in ${J}.meryl \n" # supplied by toplevel mitovgp script

sbatch $MERQ/_submit_build.sh 31 $I_LS $J

