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

printf "Species is $1 \n"
printf "Working directory is $PWD \n"

if [[ ! -d ${1}.k31.gt100.meryl ]]; then
        printf "missing meryl db in working dir.Build meryl db with submit_meryl.sh"
        exit 1
fi

printf "Will evaluate qv on $(ls ${1}*.fasta) \n"

for f in ${1}*.fasta; do
	printf "evaluating qv on $f"
	filename="${f%.*}"
	
	## Usage: ./qv.sh <read.meryl> <asm1.fasta> [asm2.fasta] <out>
	sh $MERQ/eval/qv.sh ${1}.k31.gt100.meryl $f ${1}_mt_gt100
done

printf "=======================================================\n"
printf "fasta | uniq kmers in asm | kmers in both asm and reads | QV | Error rate\n"
printf "=======================================================\n"
cat ${1}_mt_gt100.qv

printf "done!"
