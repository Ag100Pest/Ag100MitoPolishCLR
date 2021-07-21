#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

sbatch $MERQ/_submit_merqury.sh ..k20.meryl Pgos_mtDNA_contig.fasta all_k20
