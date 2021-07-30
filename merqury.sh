#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

#=== Load any modules
mitoVGP=/project/ag100pest/software/modified_mitoVGP

#=== Main program
SPECIES=$1
WD=/project/ag100pest/$SPECIES/MT_Contig

printf "Species is $1 \n"
printf "Output is $WD \n"
cd $WD


## make meryl db for qv
mkdir -p $WD/qv
ln -sf $WD/I_list.txt $WD/qv
cd $WD/qv
sbatch  $mitoVGP/submit_meryl.sh $1



#MTdir=../mitoVGP/Pectinophora_gossypiella/Pgos/assembly_MT_rockefeller/intermediates/


#meryl greater-than 100 ..k20.meryl output Pgosmt.k31.gt100.meryl
#$MERQ/merqury.sh Pgosmt.k31.gt100.meryl Pgos_mtDNA_contig.fasta allreads_k20_mt_gt100

#meryl union-sum output illumina.meryl Pectinophora_gossypiella/Pgos/assembly_MT_rockefeller/intermediates/bowtie2_round1/fq/aligned_Pgos_all*.meryl


#~/ag100pest/software/merqury/merqury.sh mitoVGP/meryl/illumina.meryl/ Pgos_mtDNA_contig.fasta mt

#cat mt.qv

#meryl greater-than 100 mitoVGP/meryl/illumina.meryl output mitoVGP/meryl/illumina.gt100.meryl

#~/ag100pest/software/merqury/merqury.sh mitoVGP/meryl/illumina.gt100.meryl Pgos_mtDNA_contig.fasta mt_gt100

#meryl difference Pgos_mtDNA_contig.meryl Pgos_k31.k31.meryl output asm.only.meryl
