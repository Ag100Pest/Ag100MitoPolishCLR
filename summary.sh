#!/bin/bash
#SBATCH -n 30
#SBATCH -p short
#SBATCH --job-name=summarize       #<= name your job
#SBATCH --output=R-%x.%J.out          # standard out goes to R-JOBNAME.12345.out
#SBATCH --error=R-%x.%J.err           # standard error goes to R-JOBBNAME.12345.err
#SBATCH --mail-user=amandastahlke@gmail.com    #<= Your email
#SBATCH --mail-type=begin
#SBATCH --mail-type=end

if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES> <JOBID>'
        Summarize the successful run oputputs of mito assmbly and annotation"
        exit 0

elif [ $1 == "-h" ]; then

        cat << EOF

        Usage: '$0 <SPECIES>'
	Summarize the successful run oputputs of mito assmbly and annotation
EOF

exit 0

fi

J=$1

printf "Summary of mito assmbly and annotation for $1 \n\n\n"

## what summary stats do we want from mitoVGP?

## number of canu contigs assembled
printf "=== intermediate mito contigs assembled \n"
grep '>' ${1}/assembly_MT_rockefeller/intermediates/canu/${J}.contigs.fasta

## mercury QV along the way
printf "\n\n=== merqury qv along the way \n"
printf "=======================================================\n"
printf "fasta | uniq kmers in asm | kmers in both asm and reads | QV | Error rate\n"
printf "=======================================================\n"
cat qv/${1}_mt_gt100.qv

## mitofinder
MF=mitofinder/$J/${J}_MitoFinder_mitfi_Final_Results
[ ! -d "$MF" ] && echo "$MF does not exist" && exit 

printf "\n\n=== MitoFinder Final Results in ${MF}/mitofinder \n"
printf "Note: Circularization in mitofinder is looking for overlaps. \n
These have likely already been trimmed in mitoVGP. \n"

cat $MF/${J}.infos 
# inital contig name
# final length
# GC content
# Circularization

TBL=$MF/${J}_mtDNA_contig.tbl
printf "\n\n=== Parsing $MF/${J}_mtDNA_contig.tbl \n"
printf "=== unique PCG (out of 13): "
grep 'product' $TBL | grep -v tRNA  | grep -v ribosomal | uniq | wc -l
printf "=== unique tRNAs (out of 22): " 
grep 'tRNA' $TBL | uniq | grep -c 'product'
printf "=== unique ribosomal RNA (out of 2): "
grep 'ribosomal' $TBL | uniq  | wc -l
printf "=== any notes: \n"
grep 'note' $TBL -B 2

printf "\n\n=== Done! \n"
