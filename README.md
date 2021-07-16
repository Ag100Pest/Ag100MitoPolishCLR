# Ag100pest mt genome pipeline
Developing this pipeline with data from the pink cotton bollworm (*Pectinophora gossypiella*), which is also being used to develop the full CLR polishing pipleline (https://github.com/isugifNF/polishCLR).  

This approach modifies the mitoVGP pipeline to assemble, polish, circularize, and annotate Ag100Pest mt genomes frm CLR + Illumina data.

This has only been tested on Scinet Ceres.

## Dependencies
**mitoVGP**

https://github.com/gf777/mitoVGP

Formenti, G., Rhie, A., Balacco, J. et al. Complete vertebrate mitogenomes reveal widespread repeats and gene duplications. Genome Biol 22, 120 (2021). https://doi.org/10.1186/s13059-021-02336-9

**mitofinder**

https://github.com/RemiAllio/MitoFinder

Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. (2020) Mol Ecol Resour. 20, 892-905. (publication link)



## Input  data
  * `PB_list.txt`: List of long reads
  * `I_list.txt`: List of shotgun short reads
  * `<reference>.fasta`: Mitochnodrial genome of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome
  * `<reference>.gb`: Mitochnodrial genbank of a closely related species. In this case, Sitotroga cerealella mitochondrion, complete genome


## Assembly

We use the mitoVGP approach to assemble, polish, and do preliminary trimming. Submit with `sbatch submit_MTAsmPolishCLR.slurm` which contains the shell script `run_mitoVGP.sh`. Currently this is hard-coded with species and parameters.

  1. `$mitoVGPdir/scripts/mtDNApipe`
    1. identifies MT-like reads by aligning long reads to reference sequence
    2. assembles contigs with canu/1.8
  2. `$mitoVGPdir/scripts/blastMT` identifies the best assembled mitocontig with blast
  3. `$mitoVGPdir/scripts/mitoPolish` polishes mitocontig with two rounds of Arrow using the same reads used by Canu
  4. `$mitoVGPdir/scripts/map10x1` polishes mitocontig with short reads by aligning to the mitocontig. A final round of freebayes and bcftools consensus is required to obtain the polished contig using the aligned outcome of the script (this step is currently not included in the script).
  5. Trimming. *This seems to be the crux.*

    1. `$mitoVGPdir/scripts/trimmer` generates a trimmed version of the Canu mitocontig after short read polishing (map10x1). The resulting contig has 100 bp overlapping ends on both sides.
      * If you need to span a long repetitive region, increase the mummer sensitivity `-z 500` to `-z 5000` (or more?)
      * If the overlapping sequences at both ends of the contig are perfectly identical, then show-coords doesn't print BEGIN and END. The grep fails and kicks out an error message, "trimming failed; try trimming with MitoFinder"
    2. If trimmer fails, use the circularization approach of mitofinder, which uses blast self-alignment to identify overlap instead.


  6. Another round of polishing to clean up trimmed ends? This is not implemented yet.

## Annotation
 7. MitoFinder. Annotations are found in `<job_name>`_MitoFinder_mitfi_Final_Results


 ## Report summary
 What all do we want here?


## TOC
* 00_Files.md
  * lists raw data
* 00a_Metadata.md
* 01_Background.md
* 02_Methods.md  
* 03_Results.md
* 04_Introduction.md
* 05_Discussion.md
* 06_AuthorInfo.md
* Notes.md
  * the bulk of where I'm documenting process, thoughs etc for now
