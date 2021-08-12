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

mkdir -p qv
cd qv
pwd

printf "Species is $1 \n"
printf "Species ID is  $2 \n"
printf "out meryl db in ${PWD}/${2}.k31.meryl \n"

sbatch $MERQ/_submit_build.sh 31 I_list.txt $2

wait_file() {
  local file="$1"; shift

  until [ -f $file ] ; do sleep 300; done
  
}

wait_file ${1}.k31.hist


## subset merqury db to kmers with at least 100x
## this should have it's own process in nextflow because it takes a while
meryl greater-than 100 ${2}.k31.meryl output ${2}.k31.gt100.meryl

sh $MERQ/eval/qv.sh ${2}.k31.gt100.meryl ${2}_mtDNA_contig.fasta ${2}_mt_gt100

cat ${SPECIES}_mt_gt100.qv



