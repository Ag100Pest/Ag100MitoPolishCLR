
module load edirect
esearch -db nucleotide -query “${1}” | \
efetch -format fasta > ${1}.fasta
