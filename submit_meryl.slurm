#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

printf "out meryl db in ${$1}.meryl" # supplied by toplevel mitovgp script

sbatch $MERQ/_submit_build.sh 31 $2 $1
