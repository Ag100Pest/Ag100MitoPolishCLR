# Ag100pest CLR+Illumina  mt genome pipeline
Developing this pipeline with data from the pink cotton bollworm (*Pectinophora gossypiella*), which is also being used to develop the full CLR polishing pipleline (https://github.com/isugifNF/polishCLR).  

This approach modifies the mitoVGP pipeline to assemble, polish, circularize, and annotate Ag100Pest mt genomes frm CLR + Illumina data.

This has only been tested on Scinet Ceres.

## Dependencies
**mitoVGP**

https://github.com/gf777/mitoVGP

Formenti, G., Rhie, A., Balacco, J. et al. Complete vertebrate mitogenomes reveal widespread repeats and gene duplications. Genome Biol 22, 120 (2021). https://doi.org/10.1186/s13059-021-02336-9

`conda env create -f mitoVGP_conda_env_pacbio.yml --prefix /project/ag100pest/software/modified_mitoVGP/pacbio_mitoVGP`

**Canu v 2.1**

Follow installation instructions here: https://github.com/marbl/canu/releases/tag/v2.1

Koren S, Walenz BP, Berlin K, Miller JR, Phillippy AM. Canu: scalable and accurate long-read assembly via adaptive k-mer weighting and repeat separation. Genome Research. (2017).


**mitofinder**

https://github.com/RemiAllio/MitoFinder

Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. (2020) Mol Ecol Resour. 20, 892-905. (publication link)

**meryl**

**merqury**

**miniconda**
To activate the mitoVGP conda environment

## Input  data
  * `PB_list.txt`: List of long reads
  * `I_list.txt`: List of shotgun short reads
  * `<reference>.fasta`: Mitochnodrial genome of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome
  * `<reference>.gb`: Mitochnodrial genbank of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome

### Reference mt genomes
Reads are assembled if they're found in the blast search against the reference mitogenome, so best to have a complete assembly.

Find closely related mitogenomes at https://goat.genomehubs.org/ 

Pull fasta or gb with EDirect suite from NCBI
`esearch -db nucleotide -query “<Accession #>” | efetch -format fasta >out.fasta`

Provided script `get_ref.sh` will download the reference fasta and genbank, provided an NCBI accession ID:
`

## Assembly

We employ mitoVGP's approach to assemble, polish, and trim. If the mitovgp trimmer fails, the pupeline kicks it out to mitofinder for trimming/circularization.  

Submit with `./submit_MTAsmPolishCLR.sh` which will submit the script `run_mitoVGP.sh` and `submit_meryl.sh` to create a meryl database for qv down the road. 

**Note**: By default, we filter any reads > 20 kb or 1.5x the reference size, whichever is bigger. 


### How it works
  1. `$mitoVGPdir/scripts/01_mtDNApipe`
    1. identifies MT-like reads by aligning long reads to reference sequence
    2. assembles contigs with canu
  2. `$mitoVGPdir/scripts/blastMT` identifies the best assembled mitocontig with blast
  3. `$mitoVGPdir/scripts/mitoPolish` polishes mitocontig with two rounds of Arrow using the same reads used by Canu
  4. `$mitoVGPdir/scripts/map10x1` polishes mitocontig with short reads by aligning to the mitocontig. A final round of freebayes and bcftools consensus is required to obtain the polished contig using the aligned outcome of the script (this step is currently not included in the script).
  5. Trimming. *This seems to be the crux.*

    * `$mitoVGPdir/scripts/trimmer` generates a trimmed version of the Canu mitocontig after short read polishing (map10x1). The resulting contig has 100 bp overlapping ends on both sides.
	* If you need to span a long repetitive region, increase the mummer sensitivity `-z 500` to `-z 5000` (or more?)
	* If the overlapping sequences at both ends of the contig are perfectly identical, then show-coords doesn't print BEGIN and END. The grep fails and kicks out an error message, "trimming failed; try trimming with MitoFinder"
	* If trimmer fails, use the circularization approach of mitofinder, which uses blast self-alignment to identify overlap instead.

  6. Another round of polishing to clean up trimmed ends? This is not implemented yet. Skip if qv doesn't find "false kmers". 

## Annotation
 7. MitoFinder. Annotations are found in `<job_name>`_MitoFinder_mitfi_Final_Results

## Report summary
 What all do we want here?
* qv checks implemented with mercury and meryl - still need to finish cleaning this up
* summary.sh prints results from mitofinder
