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

#MTDIR=/project/ag100pest/$SPECIES/RawData/MT_Contig ## hopefully a consistent directory structure will exist across projects
SPECIES=$1
J=$2 #jobid

MTDIR=/project/ag100pest/$SPECIES/RawData/MT_Contig ## hopefully a consistent directory structure will exist across projects

## what summary stats do we want from mitoVGP?
## read alignment rates
## number of canu contigs assembled
printf "=== intermediate mito contigs assembled \n"
grep '>' mitoVGP/${SPECIES}/${J}/assembly_MT_rockefeller/intermediates/canu/${J}.contigs.fasta
## lengths along the way
## mercury QV along the way

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
printf "=== unique tRNAs:"
grep 'tRNA' $TBL | uniq | grep -c 'product'
#grep 'tRNA' $TBL | uniq
printf "=== unique ribosomal RNA: "
grep 'ribosomal' $TBL | uniq  | wc -l
printf "=== any notes"
grep 'note' $TBL -B 2
