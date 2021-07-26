
module load edirect
esearch -db nucleotide -query “${1}” | \
efetch -format fasta > ref.fasta
