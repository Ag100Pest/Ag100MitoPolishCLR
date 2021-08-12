#!/bin/bash

workdir=/projects/Pgos/RawData/MT_Contig/mitoVGP/circularize

module load blast+
module load python_3
source biopython/bin/activate

cp ../Pectinophora_gossypiella/Pgos_2/assembly_MT_rockefeller/intermediates/trimmed/Pgos_2.tig00000001_polish2_10x1_new.fasta .

### definitely want to capture std err in a log
python circularizationCheck.py Pgos.tig00000001_polish2_10x1_new.fasta

