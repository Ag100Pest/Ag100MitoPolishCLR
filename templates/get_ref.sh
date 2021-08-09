
module load edirect
esearch -db nucleotide -query “${1}” | \
efetch -format fasta > ref.fasta

esearch -db nucleotide -query “${1}” | \
efetch -format gb > ref.gb

