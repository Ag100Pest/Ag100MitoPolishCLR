# Ag100pest CLR+Illumina  mt genome pipeline

This approach builds upon the mitoVGP pipeline (https://github.com/gf777/mitoVGP) to assemble, polish, circularize, qv check, and annotate Ag100Pest mt genomes frm CLR + Illumina data.

## Dependencies
**mitoVGP**

https://github.com/gf777/mitoVGP

Formenti, G., Rhie, A., Balacco, J. et al. Complete vertebrate mitogenomes reveal widespread repeats and gene duplications. Genome Biol 22, 120 (2021). https://doi.org/10.1186/s13059-021-02336-9

`conda env create -f mitoVGP_conda_env_pacbio.yml --prefix /project/ag100pest/software/modified_mitoVGP/pacbio_mitoVGP`

**mitofinder**

https://github.com/RemiAllio/MitoFinder

Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. (2020) Mol Ecol Resour. 20, 892-905. (publication link)

## Input  data
  * `PB_list.txt`: List of long reads
  * `I_list.txt`: List of shotgun short reads
  * `<reference>.fasta`: Mitochnodrial genome of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome
  * `<reference>.gb`: Mitochnodrial genbank of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome

**Mercury and Meryl**

## Basic Usage
Export software directory to your path. Add this to .bashrc to 
`export PATH="/project/ag100pest/software/modified_mitoVGP/:$PATH"`

Download reference.fasta and refererence.gb from a closely related species. 
`get_ref.sh <MT ACCESSION ID>`

Prepare expected inputs I_list.txt for Illumina Polishing and PB_list.txt with subreads.bam. Eg `ls /project/ag100pest/Illumina_polishing/JAMU*{R1,R2}.fastq.bz2 > I_list.txt`

submit_


### Reference mt genomes
Reads are assembled if they align against the reference mitogenome, so best to have a complete assembly.  
Find closely related mitogenomes at https://goat.genomehubs.org/ 
Pull fasta or gb with EDirect suite from NCBI
`esearch -db nucleotide -query “<Accession #>” | efetch -format fasta >out.fasta`

## Assembly

We use the mitoVGP approach to assemble, polish, and do preliminary trimming. Submit with `sbatch submit_MTAsmPolishCLR.slurm` which contains the shell script `run_mitoVGP.sh`. Currently this is hard-coded with species and parameters.

  1. `$mitoVGPdir/scripts/01_mtDNApipe`
    1. identifies MT-like reads by aligning long reads to reference sequence
    2. assembles contigs with canu/1.8
  2. `$mitoVGPdir/scripts/02_blastMT` identifies the best assembled mitocontig with blast
  3. `$mitoVGPdir/scripts/03_mitoPolish` polishes mitocontig with two rounds of Arrow using the same reads used by Canu
  4. `$mitoVGPdir/scripts/04_map10x1` polishes mitocontig with short reads by aligning to the mitocontig
  5. `$mitoVGPdir/scripts/05_trimmer` generates a trimmed version of the Canu mitocontig after short read polishing (map10x1). The resulting contig has 100 bp overlapping ends on both sides.
* If you need to span a long repetitive region, increase the mummer sensitivity `-z 500` to `-z 5000` (or more?)
* If the overlapping sequences at both ends of the contig are perfectly identical, then show-coords doesn't print BEGIN and END. The grep fails and kicks out an error message, "trimming failed; trimming with MitoFinder". Then we use the circularization approach of mitofinder, which uses a blast self-alignment to identify overlap instead.
  6. Another round of polishing to clean up trimmed ends.  This is not implemented yet. Skip if qv doesn't find "false kmers". 

## Annotation
 MitoFinder. Annotations are found in `<job_name>`_MitoFinder_mitfi_Final_Results

## Report summary
summary.sh prints results from mitofinder
