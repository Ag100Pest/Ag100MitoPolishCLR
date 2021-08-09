#! /usr/bin/env bash

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury

$MERQ/_submit_build.sh $k $illumina_reads $species
