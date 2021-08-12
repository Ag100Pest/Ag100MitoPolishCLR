
ID=$1
W_URL=${ID}/assembly_MT_rockefeller/intermediates

cp ${W_URL}/polish/polish_round1/${ID}.tig*.fasta qv/
cp ${W_URL}/polish/polish_round1/${ID}.tig*_polish.fasta qv/
cp ${W_URL}/polish/polish_round2/${ID}.tig*_polish2.fasta qv/
cp ${W_URL}/freebayes_round1/${ID}.tig*_polish2_10x1.fasta qv/
FNAME="${ID}.tig*_polish2_10x1_trim1"
cp ${W_URL}/freebayes_round2/${FNAME}_10x2.fasta qv/
cp ${ID}/${ID}_MitoFinder_mitfi_Final_Results/${ID}_mtDNA_contig.fasta qv/

