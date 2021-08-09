#! /usr/bin/env bashi

module load merqury/1.1
module load meryl/1.0

MERQ=/project/ag100pest/software/merqury


$MERQ/merqury.sh ${species}.k31.gt100.meryl $mt_asm ${species}_mt_gt100


