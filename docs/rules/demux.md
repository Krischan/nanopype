# Demultiplexing

With barcoded libraries nanopore sequencing allows to pool multiple samples on a single flow cell. Demultiplexing describes the classification of barcodes per read and the assignment of read groups. The output of the demultiplexing module is a tsv file of read ID and detected barcode. In order to process a barcoded flow cell with e.g. Deepbinner run:

    snakemake --snakefile /path/to/nanopype/Snakefile demux/deepbinner/20180101_FAH12345_FLO-MIN106_SQK-RBK004_WA01.tsv

Note the different sequencing kit *SQK-RBK004* used in this example.

## Folder structure

The demultiplexing module can create the following file structure relative to the working directory:

```sh
|--demux/
   |--albacore/                                            # Albacore basecaller
      |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01/
         |--0.tsv                                          # Demultiplexed batches
         |--1.tsv
          ...
      |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01.tsv
   |--albacore.tsv
   |--deepbinner/                                          # Deepbinner neural network
      |--20180101_FAH12345_FLO-MIN106_SQK-LSK108_WA01/
         |--0.tsv                                          # Demultiplexed batches
         |--1.tsv
          ...
   |--deepbinner.tsv
```

## Tools

The demultiplexing module includes the following tools and their respective configuration:

### Albacore

The ONT basecaller directly supports demultiplexing in sequence space.

    basecalling_albacore_barcoding: true

### Deepbinner

Deepbinner: Demultiplexing barcoded Oxford Nanopore Technologies reads with deep convolutional neural networks (CNN). The network is trained to classify barcodes based on the raw nanopore signal. The model for the CNN needs to be copied from the Deepbinner repository to the working directory and depends on the used sequencing kit. The kit is parsed from the run name as described in the [configuration](../installation/configuration.md).

    threads_demux: 4
    deepbinner_models:
        default: SQK-RBK004_read_starts
        EXP-NBD103: EXP-NBD103_read_starts
        SQK-RBK004: SQK-RBK004_read_starts

## References

> Wick, R. R., Judd, L. M. & Holt, K. E. Deepbinner: Demultiplexing barcoded Oxford Nanopore reads with deep convolutional neural networks. PLOS Computational Biology 14, e1006583 (2018).
