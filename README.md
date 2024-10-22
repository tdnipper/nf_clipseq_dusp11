# nf_CLIPseq_DUSP11
A repository hosting a custom nextflow pipeline for analyzing DUSP11 CLIP-seq data.

## Overview
DUSP11 is an RNA triphosphatase that resides in the nucleus where it may process triphosphates from non-capped RNAs to prevent their aberrant activation of RIG-I and the innate immune system. 
We are interested in profiling the RNA binding repertoire of DUSP11 to see what RNAs it processes. This pipeline takes RNA-seq reads from a DUSP11 CLIP-seq experiment, preprocesses, aligns to the human genome, finds crosslinks, and calls significant crosslinking peaks.
This returns bedgraphs of xlinks, and bed files of peaks.

## Running the pipeline
Raw data must be in a raw_data directory in the root directory of the pipeline. CPU #s and other program specific settings can be configured manually in the nextflow.config file. Once ready, run the pipeline using `nextflow run main.nf`.
