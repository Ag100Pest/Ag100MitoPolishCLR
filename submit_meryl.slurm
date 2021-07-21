#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

sbatch $MERQ/_submit_build.sh 31 ../mitoVGP/I_list.txt Pgos_k31
