#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

ln -s ../Pgos_mtDNA_contig.fasta .

## find optimal kmer size
## Should the genome size and k be optimized for the mtgenome or the organism genome?
## mitoVGP paper uses k=31
k=$(~/ag100pest/software/merqury/best_k.sh 16000 | tail -n 1)

MTdir=../mitoVGP/Pectinophora_gossypiella/Pgos/assembly_MT_rockefeller/intermediates/

illumina_reads=$( ls $MTdir/bowtie2_round1/fq/*_{1,2}.fq)
illumina_reads=$(cat $MTdir/I_list.txt)

for i in $illumina_reads; do 
	name=$(basename $i | cut -f 1 -d .)
	meryl count k=$k output ${name}.meryl ${i}
done
# output is to Pectinophora_gossypiella/Pgos/assembly_MT_rockefeller/intermediates//bowtie2_round1/fq/, probably want to sym link to a distinct directory instead

## next time provide a legit pre-fix
sbatch $MERQ/_submit_build.sh 20 ../mitoVGP/I_list.txt .
## "Usage: ./_submit_meryl2_build.sh <k-size> <input.fofn> <out_prefix> [mem=T]"
ls -a ..k20.meryl
meryl greater-than 100 ..k20.meryl output Pgosmt.k31.gt100.meryl
$MERQ/merqury.sh Pgosmt.k31.gt100.meryl Pgos_mtDNA_contig.fasta allreads_k20_mt_gt100

meryl union-sum output illumina.meryl Pectinophora_gossypiella/Pgos/assembly_MT_rockefeller/intermediates/bowtie2_round1/fq/aligned_Pgos_all*.meryl


~/ag100pest/software/merqury/merqury.sh mitoVGP/meryl/illumina.meryl/ Pgos_mtDNA_contig.fasta mt

cat mt.qv
## Pgos_mtDNA_contig    0    15198    inf    0
## this didn't work

## 
meryl greater-than 100 mitoVGP/meryl/illumina.meryl output mitoVGP/meryl/illumina.gt100.meryl

~/ag100pest/software/merqury/merqury.sh mitoVGP/meryl/illumina.gt100.meryl Pgos_mtDNA_contig.fasta mt_gt100

meryl difference Pgos_mtDNA_contig.meryl Pgos_k31.k31.meryl output asm.only.meryl
