#!/bin/bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=meryl_merq        #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

SPECIES=$1
WD=/project/ag100pest/$SPECIES/MT_Contig/qv

printf "Species is $1 \n"
printf "Changing to working directory $WD \n"
cd $WD

if [[ ! -d ${1}.k31.meryl ]]; then
        printf "missing meryl db in working dir.Build meryl db with submit_meryl.sh"
        exit 1
fi

## subset merqury db to kmers with at least 100x
## this should have it's own process in nextflow because it takes a while
meryl greater-than 100 ${1}.k31.meryl output ${1}.k31.gt100.meryl

#$MERQ/merqury.sh ${1}.k31.gt100.meryl ${1}_mtDNA_contig.fasta ${1}_mt_gt100

ln -sf /project/ag100pest/$SPECIES/MT_Contig/${1}/${1}_MitoFinder_mitfi_Final_Results/${1}_mtDNA_contig.fasta .

sh $MERQ/eval/qv.sh ${SPECIES}.k31.gt100.meryl ${SPECIES}_mtDNA_contig.fasta ${SPECIES}_mt_gt100

cat ${SPECIES}_mt_gt100.qv

#sbatch $MERQ/_submit_merqury.sh ${1}.k31.meryl ${1}_mtDNA_contig.fasta all_k20
