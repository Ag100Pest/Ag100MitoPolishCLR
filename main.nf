#! /usr/bin/env nextflow

nextflow.enable.dsl=2

def helpMessage() {
  log.info """
   Usage:
   The typical command for running the pipeline are as follows:
   nextflow run main.nf --species "Pgos" --ref "NC_041123" --illumina_reads "*{1,2}.fastq.bz2" --pacbio_reads "*_subreads.bam" -resume
   Mandatory arguments:
   --illumina_reads               paired end illumina reads, to be used for Merqury QV scores, and freebayes polish primary assembly
   --pacbio_reads                 pacbio reads in bam format, to be used to arrow polish primary assembly
   --species                      if a string is given, rename the final assembly by species name
   --ref			  NCBI locus ID for reference mt assembly to make seed fasta and genbank
   Optional modifiers
   --k                            kmer to use in MerquryQV scoring [default:31]
   --parallel_app                 Link to parallel executable [default: 'parallel']
   --bzcat_app                    Link to bzcat executable [default: 'bzcat']
   --pigz_app                     Link to pigz executable [default: 'pigz']
   --meryl_app                    Link to meryl executable [default: 'meryl']
   --merqury_sh                   Link to merqury script [default: '\$MERQURY/merqury.sh']
   --pbmm2_app                    Link to pbmm2 executable [default: 'pbmm2']
   --samtools_app                 Link to samtools executable [default: 'samtools']
   --gcpp_app                     Link to gcpp executable [default: 'gcpp']
   --bwamem2_app                  Link to bwamem2 executable [default: 'bwa-mem2']
   --freebayes_app                Link to freebayes executable [default: 'freebayes']
   --bcftools_app                 Link to bcftools executable [default: 'bcftools']
   --merfin_app                   Link to merfin executable [default: 'merfin']
   Optional arguments:
   --outdir                       Output directory to place final output [default: 'MitoPolishCLR_Results']
   --clusterOptions               Cluster options for slurm or sge profiles [default slurm: '-N 1 -n 40 -t 04:00:00'; default sge: ' ']
   --threads                      Number of CPUs to use during each job [default: 40]
   --queueSize                    Maximum number of jobs to be queued [default: 50]
   --account                      Some HPCs require you supply an account name for tracking usage.  You can supply that here.
   --help                         This usage statement.
  """
}

// Show help message
if (params.help || !params.species || !params.illumina_reads || !params.pacbio_reads ) {
  helpMessage()
  exit 0
}

// 00 Preprocess: Get NCBI ref fasta anad genbank
process getref {
    publishDir "${params.outdir}/00_ref", mode: 'copy'
    input:  val(ref_ch)
    output: tuple val(reffasta), val(refgb) 
    script:
    template 'getref.sh'
}

// 00 Preprocess: Create meryl db for qv
process meryldb {
    publishDir "${params.outdir}/qv", mode: 'symlink'
    input:  tuple val(k) val(ill_ch)
    output: path("*") 
    script:
    template 'meryldb.sh'
}

//
process merylsubset{
   publishDir "${params.outdir}/qv", mode: 'symlink' //maybe this doesn't need to be published
   input: val(meryldb)
   output: val(subsetmeryldb)  
   template 'merylsubset.sh'
}

workflow {
    // Setup input channels, species name (sp), reference id (ref),  Illumina reads (ill), and pacbio reads (pac)
    sp_ch  = channel.of(params.species, checkIfExists:true)
    ref_ch = channel.of(params.ref, checkIfExists:true)
    ill_ch = channel.fromFilePairs(params.illumina_reads, checkIfExists:true)
    pac_ch = channel.fromPath(params.pacbio_reads, checkIfExists:true)

    // k_ch   = channel.of(params.k) // Either passed in or autodetect (there's a script for this)

   // 00 Preprocess: Get NCBI ref fasta anad genbank
   ref_ch | getref

   // 00 Preprocess: Create meryl db for qv
   ill_ch | meryldb 

    }


