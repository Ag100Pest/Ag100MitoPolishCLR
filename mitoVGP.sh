#!/bin/bash

set -e -o pipefail

if [ -z $1 ]; then

	echo "use $0 -h for help"
	exit 0
elif [ $1 == "-h" ]; then

	cat << EOF

	Usage: '$0 -s species -i species_ID -r reference -g genome_size -t threads [-m mapper -l filelist -f size_cutoff -o canu_options]'

	mitoVGP is used for reference-guided de novo mitogenome assembly using a combination of long and short read data.
	
	Existing reference from closely to distantly related species is used to identify mito-like reads in WGS data,
	which are then employed in de novo genome assembly.
	
	Check the github page https://github.com/GiulioF1/mitoVGP for a description of the pipeline.
	A complete Conda environment with all dependencies is available to run the pipeline in the same github page.
	
	This script a simple wrapper of the scripts found in the scripts/ folder. You can find more information
	on each step in the help (-h) of each script.

	Required arguments are:
	-s the species name (e.g. Calypte_anna)
	-i the VGP species ID (e.g. bCalAnn1)
	-r the reference sequence fasta file
	-t the number of threads
	
	Optional arguments are:
	-g the putative mitogenome size (potentially, that of the reference genome). If not provided, length of reference is used.
	It does not need to be precise. Accepts Canu formatting.
	-d multithreaded download of files (true/false default: false) !! warning: it may require considerable amount of space.
	-l use files from list of files (default looks into aws)
	-m the aligner (blasr|minimap2|pbmm2). Default is pbmm2
	-f filter reads by size prior to assembly (reduces the number of NUMT reads and helps the assembly)
	-o the options for Canu

EOF

exit 0

fi

#set options

while getopts ":s:i:r:g:t:d:l:m:f:o:" opt; do

	case $opt in
		s)
			SPECIES=$OPTARG
			;;
        i)
        	ID=$OPTARG
            ;;
        r)
			REF=$OPTARG
			;;
		g)
			GSIZE=$OPTARG
            ;;
		t)
			NPROC=$OPTARG
            ;;
		d)
			DOWNL=$OPTARG
            ;;
		l)
			LIST=$OPTARG
			;;
		m)
			ALN=$OPTARG
			;;
		f)
            FL=$OPTARG
			;;
		o)
            OPTS=$OPTARG
			;;
		\?)
			echo "ERROR - Invalid option: -$OPTARG" >&2
			exit 1
			;;
	esac

done

printf "\n\n++++                        mitoVGP v2.0                         ++++\n"
printf "++++ The Vertebrate Genomes Project Mitogenome Assembly Pipeline ++++\n"
printf "++++     Credit: Giulio Formenti gformenti@rockefeller.edu       ++++\n\n"

#define working directory
W_URL=${SPECIES}/assembly_MT_rockefeller/intermediates

if ! [[ -e "${W_URL}" ]]; then

	mkdir -p ${W_URL}

fi

if ! [[ -e "${W_URL}/log" ]]; then

	mkdir ${W_URL}/log

fi

#copy the user-provided reference mitogenome to the reference folder
if ! [[ -e "${W_URL}/reference" ]]; then

	mkdir ${W_URL}/reference
	cp ${REF} ${W_URL}/reference/${REF%.*}.fasta

fi

if [[ -z  ${GSIZE} ]]; then
	
	GSIZE=$(awk 'BEGIN {FS="\t"} $0 !~ ">" {sum+=length($0)} END {print sum}' ${W_URL}/reference/${REF%.*}.fasta)
	
	printf "\nGenome size not provided, using reference genome size: ${GSIZE} bp\n"
	
fi

#retrieve mito-like reads and assemble
sh -e scripts/mtDNApipe.sh -s ${SPECIES} -i ${ID} -r ${REF} -g ${GSIZE} -t ${NPROC} -d ${DOWNL} -o ${OPTS} 2>&1 | tee ${W_URL}/log/${ID}_mtDNApipe_$(date "+%Y%m%d-%H%M%S").out &&

#identify the mitocontig
sh -e scripts/blastMT.sh -s ${SPECIES} -i ${ID} -r ${REF} 2>&1 | tee ${W_URL}/log/${ID}_blastMT_$(date "+%Y%m%d-%H%M%S").out &&
CONTIG_ID=$(cat ${W_URL}/blast/${ID%.*.*}_candidate_mitocontig.txt) &&

#polish the mitocontig with long reads
sh -e scripts/ArrowPolish.sh -s ${SPECIES} -i ${ID} -n ${CONTIG_ID} -t ${NPROC} 2>&1 | tee ${W_URL}/log/${ID}_ArrowPolish_$(date "+%Y%m%d-%H%M%S").out &&

#polish the mitocontig with short reads
sh -e scripts/map10x1.sh -s ${SPECIES} -i ${ID} -n ${CONTIG_ID} -t ${NPROC} -d ${DOWNL} 2>&1 | tee ${W_URL}/log/${ID}_map10x1_$(date "+%Y%m%d-%H%M%S").out &&

#trim the mitocontig
sh -e scripts/trimmer.sh -s ${SPECIES} -i ${ID} -n ${CONTIG_ID} -t ${NPROC} 2>&1 | tee ${W_URL}/log/${ID}_trimmer_$(date "+%Y%m%d-%H%M%S").out &&

#polish the trimmed mitocontig with short reads
sh -e scripts/map10x2.sh -s ${SPECIES} -i ${ID} -n ${CONTIG_ID} -t ${NPROC} 2>&1 | tee ${W_URL}/log/${ID}_map10x2._$(date "+%Y%m%d-%H%M%S")out &&

#perform final end trimming
sh -e scripts/trimmer2.sh -s ${SPECIES} -i ${ID} -n ${CONTIG_ID} -t ${NPROC} 2>&1 | tee ${W_URL}/log/${ID}_trimmer2_$(date "+%Y%m%d-%H%M%S").out &&

printf "\n\nDone!" &&
printf "\n$(date "+%Y%m%d-%H%M%S")"