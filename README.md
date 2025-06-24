# Sunp
simplified unified nanopore pipeline aka sunp (Saccharomyces ONT T2T assembly)
To be used for R10 nano-hq only 

[![Licence](https://img.shields.io/github/license/nicolo-tellini/intropipeline?style=plastic)](https://github.com/nicolo-tellini/sunp/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/intropipeline?style=plastic)](https://github.com/nicolo-tellini/sunp/releases/tag/v.1.0.0)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/intropipeline?color=yellow&style=plastic)](https://github.com/nicolo-tellini/sunp/graphs/commit-activity)

## Description



## Workflow

`initiate` defines and creates necessary directories. `precontig` anticipates the assembly phase filtering the reads according to specified parameters [default: minimum length 10 kb and 30X coverage]. `contig` and  `contig4` perform de novo assembling with `Flye` and `hifiasm`, respectively. Once assembled, `seqkit` removes unwanted white spaces while `QUAST` and `BUSCO` assess the raw assembly's quality and completeness. `assessment_after_contings` run `MUMmer` against the reference genome in `rep` dir, this is an intermeidiate control step. `Polishing` runs the raw assembly polishing according to the following scheme: 
1) one round correction with ONT reads `minimap2-racon`
2) `medaka consensus`
3) one round correction with Illumina reads `bwa-pilon`

`scaffolding2` performs the scaffolding in reference-free mode with `ntLink` while `telofinder` detects the number of terminal (and eventually internal) telomeric regions.
 while `MUM&CO` recovers structural variants from pairwise comparison with a reference genome.
`assign_cent` extract CEN from the reference genome annotation and receover them from the de novo assebly. The presence of the CEN on a contig determine the chromosomes naming and order (`reorderscaffolds`). 
Visual inspection of the alignment against a reference genome. 
Mulitple CEN on the same contig are artifacts and results in double named chromosomes such as `IV_XIII`.
`assessment_after_scaffolding` performs a last `MUMmer` against the reference genome structure assessment.
In order to assess and deal with artefact the pipeline run `backmapping` and `annotation`. The former maps the filtered long reads back to the de novo assemblies generated, while annotation is a quick way to identify and annotate functional genes which aims to give an overview of genes distribution across the assembly (!!! please note that the purpose of this step is not a coemprihensive whole-genome annotation). 

In case of artifact the long reads will show: 
1) local accumuation of unexpected SNPs,
2) drastic coverage drop
3) strong read clipping.

<p align="center">
  <img src="https://github.com/nicolo-tellini/sunp/blob/main/artifact_eaxample.png" alt="Artifact ont"/>
</p>

This requires manual curation.

## Download
 
:octocat: :
  
```sh
git clone --recursive https://github.com/nicolo-tellini/intropipeline.git
```

## Content

:open_file_folder: :

```{bash}
.
├── rep
│   ├── Ann
│   └── Asm
├── runner.sh
├── scr
└── seq

5 directories 1 file
```

- ```rep``` : repository with assemblies, annotations and pre-computed marker table,</br>
- ```runner.sh``` : the script you edit and run,</br>
- ```scr``` : scripts,</br>
- ```seq``` : put the FASTQs files here,</br>

### Before starting 

``` gzip -d ./rep/mrktab.gz ```

``` gzip -d ./rep/Asm/*gz```

### About the fastqs 

Move the FASTQs inside ```./seq/```

Paired-end FASTQs data **must** be gziped and suffixed with **.R1.fastq.gz** and **.R2.fastq.gz**.

### Default 

```./scr/bwa.sh``` uses 2 thread for sample (n.samples = 2).

```./scr/samtools_markers.sh``` uses 1 thread for sample (n.samples = 4).

```./scr/gem.sh``` uses 2 threads.

```./scr/freec.sh``` uses 4 threads.

these values can be changed editing the scripts.

### How to run

Edit ```runner.sh``` :page_with_curl: 

```{bash}
#!/bin/bash

#####################
### user settings ###
#####################

## S. paradoxus reference assembly

ref2Label="CBS432" ## choose the Spar assembly you think better fit the origin of your samples

## short labels (used to name file)

ref2="EU" ## choose a short name for Spar

# STEP 1
fastqQC="yes" ## fastqc control (required) ("yes","no" or "-" the last is skip)

# STEP 2
shortReadMapping="yes" ## ("yes","no")

# STEP 3
mrkgeno="yes" ## ("yes","no")

# STEP 4
cnv="yes" ## ("yes","no")

# STEP 5
intro="yes" ## ("yes","no")

#####################
### settings' end ###
#####################
```

Run ```runner.sh``` :runner: 

```{bash}
nohup bash runner.sh &
```

# Dependencies 
The following tools can be installed via conda (recommended)
- Filtlong v0.2.1
- NanoPlot 1.44.1
- Flye 2.9.5-b1801
- seqkit v2.10.0
- QUAST v5.3.0
- BUSCO 5.8.2
- minimap2 2.29-r1283
- racon 1.5.0
- medaka 2.0.1
- bwa 0.7.19-r1273
- samtools 1.21
- Pilon version 1.24
- ragtag v2.1.0
- telofinder
- ntLink v1.3.11
- mumandco_v3.8
- hifiasm 0.25.0-r726
# R packages 
- seqinr
- data.table
- ggplot2
- viridis
- ggExtra
