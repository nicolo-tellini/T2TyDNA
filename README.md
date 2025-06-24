# Sunp
simplified unified nanopore pipeline aka sunp (Saccharomyces ONT T2T assembly)


[![Licence](https://img.shields.io/github/license/nicolo-tellini/intropipeline?style=plastic)](https://github.com/nicolo-tellini/sunp/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/intropipeline?style=plastic)](https://github.com/nicolo-tellini/sunp/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/intropipeline?color=yellow&style=plastic)](https://github.com/nicolo-tellini/sunp/graphs/commit-activity)

## Description
To be used for R10 nano-hq only 


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
git clone --recursive https://github.com/nicolo-tellini/sunp.git
```

## Content

:open_file_folder: :

```{bash}
.
├── rep
│    └── README
├── scr
└── seq

3 directories 
```

- ```rep``` : repository with ref. assembly and annotations (see ScRapDB),</br>
- ```scr``` : scripts,</br>
- ```seq``` : put the FASTQs files here,</br>

### About the fastqs 

Paired-end FASTQs data **must** be gziped and suffixed as sample**.fastq.gz** (ont) and sample**_1.fastq.gz** and sample**_2.fastq.gz** (Illumina).

### How to run

Edit USER VARIABLE in the ```./scr/config``` :page_with_curl: 

```{bash}
###########################################################
#                   CONFIGURATION FILE                    #
#                                                         #
# This configuration file sets parameters for sample      #
# processing and analysis. Modify these values according  #
# to your project's requirements.                         #
#                                                         #
#                                			  #
# Contact me at nicolo.tellini.2@gmail.com		  #
###########################################################

##########################################################
#		     USER VARIABLE			 #
##########################################################

     		 
nt=8 # Number of threads
inds=yS881 # Sample name
ref_genome=SGDref.asm01.HP0.nuclear_genome.tidy.fa # Name of the reference genome file
ref_ann=SGDref.asm01.HP0.nuclear_genome.tidy.gff3 # Name of the annotation file
```

Run ```runner.sh``` :runner: 

```{bash}
bash runner.sh &
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
