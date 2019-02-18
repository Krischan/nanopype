# Alignment

The alignment step maps basecalled reads against a reference genome. If not already done alignment rules will trigger basecalling of the raw nanopore reads.

To align the reads of one flow cell against reference genome hg38 with *flappie* basecalling and aligner *minimap2* run from within your processing directory:

    snakemake --snakefile /path/to/nanopype/Snakefile alignments/minimap2/flappie/runs/20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01.hg38.bam

This requires an entry *hg38* in your **env.yaml** in the nanopype installation directory:

    references:
        hg38:
            genome: /path/to/references/hg38/hg38.fa
            chr_sizes: /path/to/references/hg38/hg38.chrom.sizes

Providing a *runnames.txt* with one runname per line it is possible to process multiple flow cells at once and merge the output into a single track e.g.:

    snakemake --snakefile /path/to/nanopype/Snakefile alignments/minimap2/flappie/WA01.hg38.bam

Some aligners require an indexed reference genome, nanopype will automatically build one uppon first use. An alignment job is always connected with a sam2bam conversion and sorting in an additonal thread. The above commands with 3 configured alignment threads will therefore fail if snakemake is invoked with less than 4 threads (at least *-j 4* is required). The default input sequence format for alignment rules is *fastq*, yet if possible, the alignment module will use already basecalled batches in the sequences/[basecaller]/[runname]/ folder of the working directory.

## Folder structure

The alignment module can create the following file structure relative to the working directory:

```sh
|--alignments/
   |--minimap2/                                                 # Minimap2 alignment
      |--albacore/                                              # Using albacore basecalling
         |--runs
            |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01/
               |--0.hg38.bam
               |--1.hg38.bam
               ...
            |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01.hg38.bam
         |--WA01.hg38.bam
   |--graphmap/                                                 # GraphMap alignment
      |--flappie/                                               # Using flappie basecalling
         |--runs
            |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01/
               |--0.hg19.bam
               ...
            |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01.hg19.bam
         |--WA01.hg19.bam
```

## Tools

The default basecaller for alignments can be configured in the **config.yaml** of the working directory. Depending on the application you can choose from one of the listed aligners. All alignment rules share a set of global config variables:

:   * threads_alignment: 3

### Minimap2

Pairwise alignment for nucleotide sequences. Any given command line arguments are directly passed to the aligner:

:   * alignment_minimap2_flags: '-ax map-ont -L'

### GraphMap

Fast and sensitive mapping of nanopore sequencing reads with GraphMap. Any given command line arguments are directly passed to the aligner:

:   * alignment_graphmap_flags: '-B 100'

### NGMLR

Accurate detection of complex structural variations using single-molecule sequencing. Any given command line arguments are directly passed to the aligner:

:   * alignment_ngmlr_flags: '-x ont --bam-fix'

## References

>Li, H. Minimap2: pairwise alignment for nucleotide sequences. Bioinformatics. doi:10.1093/bioinformatics/bty191 (2018).

>Sovic, I. et al. Fast and sensitive mapping of nanopore sequencing reads with GraphMap. Nat. Commun. 7:11307 doi: 10.1038/ncomms11307 (2016).

>Sedlazeck, F. J. et al. Accurate detection of complex structural variations using single-molecule sequencing. Nature Methods 15, 461-468 (2018).
