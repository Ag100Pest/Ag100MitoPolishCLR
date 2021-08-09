#!/bin/bash
if [ -z $1 ]; then

        printf "Usage: '$0 <SPECIES> <JOBID>'
        Summarize the successful run oputputs of mito assmbly and annotation"
        exit 0

elif [ $1 == "-h" ]; then

        cat << EOF

        Usage: '$0 <SPECIES> <JOBID>'
	Summarize the successful run oputputs of mito assmbly and annotation
EOF

exit 0

fi

SPECIES=$1
J=$2 # species or job id

MTDIR=/project/ag100pest/$SPECIES/MT_Contig ## hopefully a consistent directory structure will exist across projects

## what summary stats do we want from mitoVGP?
## read alignment rates
## number of canu contigs assembled
printf "=== intermediate mito contigs assembled \n"
grep '>' ${MTDIR}/${J}/assembly_MT_rockefeller/intermediates/canu/${J}.contigs.fasta
## lengths along the way

## mercury QV along the way
printf "===  \n"
#sbatch $MERQ/_submit_merqury.sh .meryl Pgos_mtDNA_contig.fasta all_k20


## mitofinder
MF=$MTDIR/mitofinder/$J/${J}_MitoFinder_mitfi_Final_Results
[ ! -d "$MF" ] && echo "$MF does not exist" && exit 

printf "MitoFinder Final Results in $MTDIR/mitofinder \n"
cat $MF/${J}.infos 
# inital contig name
# final length
# GC content
# Circularization

## Are all tRNAs uniquely represented?

TBL=$MF/${J}_mtDNA_contig.tbl
printf "=== Parsing $MF/${JOBID}_mtDNA_contig.tbl \n"
printf "=== unique PCG (out of 13):"
grep 'product' Otur_mtDNA_contig.tbl | grep -v tRNA  | grep -v ribosomal | uniq | wc -l
printf "=== unique tRNAs (out of 22):"
grep 'tRNA' $TBL | uniq | grep -c 'product'
printf "=== unique ribosomal RNA (out of 2): "
grep 'ribosomal' $TBL | uniq  | wc -l
printf "=== any notes\n"
grep 'note' $TBL -B 2
