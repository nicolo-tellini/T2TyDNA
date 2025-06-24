# Sunp
simplified unified nanopore pipeline aka sunp (Saccharomyces ONT T2T assembly)


[![Licence](https://img.shields.io/github/license/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/sunp/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/sunp/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/sunp?color=yellow&style=plastic)](https://github.com/nicolo-tellini/sunp/graphs/commit-activity)


## Description
This pipeline is designed for hybrid assemblies using **Oxford Nanopore R10.4 high-quality reads** (nano-HQ) and **Illumina paired-end (PE) reads** only.  
If you are working with older Nanopore chemistries or single-end Illumina data, you will need to modify the workflow accordingly. These use cases are **not supported** by default.

### Purpose

This repository is intended for:

1. Ensuring **reproducibility** of hybrid genome assembly and annotation workflows.
2. Running **new strains** for which both R10.4 and Illumina PE data are available.

> ⚠️ **Note**: This pipeline is provided as-is. It will **not** be adapted for individual or legacy use cases.

---

### Annotation Step

The annotation process uses **eggNOG-mapper**, which requires a **local database** not included in the repository.  
To set it up manually:

```bash
download_eggnog_data.py --data_dir $HOME/eggnog_db
```
The pipeline expects to find the eggNOG database in:
```bash
$HOME/eggnog_db
```
If your database is located elsewhere, update the relevant variable in the config file accordingly.

Issues & Support

If you encounter problems, please open an issue and include the full contents of the logs directory.

## Workflow

The pipeline consists of multiple sequential modules tailored for hybrid genome assembly, polishing, quality control, and basic annotation. Below is an overview of each step:

### 1. Initialization & Pre-processing

- **`initiate`**: Sets up the directory structure and required files.
- **`precontig`**: Filters long reads prior to assembly, based on user-defined thresholds  
  *(default: minimum read length = 10 kb, target coverage = 30×)*.

### 2. Assembly

- **`contig`**: Performs de novo assembly using **Flye**.
- **`contig4`**: Alternative assembly with **hifiasm**.
- **`seqkit`**: Removes unwanted whitespace characters from assemblies.
- **`QUAST`** and **`BUSCO`**: Evaluate assembly quality and gene completeness.

### 3. Intermediate Assessment

- **`assessment_after_contigs`**: Aligns the draft assembly to a reference genome using **MUMmer**  
  *(reference genome must be placed in the `rep/` directory)*.

### 4. Polishing

A three-step polishing process:

1. **`minimap2` + `racon`**: One round of correction with ONT reads.
2. **`medaka`**: Generates high-quality consensus.
3. **`bwa` + `pilon`**: One round of correction using Illumina reads.

### 5. Scaffolding & Telomere Detection

- **`scaffolding2`**: Reference-free scaffolding with **ntLink**.
- **`telofinder`**: Detects telomeric repeats (both terminal and internal).

### 6. Structural Variant Recovery & Centromere Assignment

- **`MUM&CO`**: Detects structural variants via pairwise alignment with the reference genome.
- **`assign_cent`**: Extracts centromere positions from the reference annotation and maps them to the new assembly.
- **`reorderscaffolds`**: Names and orders scaffolds based on centromere positions.

> If multiple centromeres are found on the same contig (e.g., `IV_XIII`), this likely indicates an assembly artifact requiring manual inspection.

### 7. Final Assessment

- **`assessment_after_scaffolding`**: Final structural comparison against the reference using **MUMmer**.

### 8. Backmapping & Annotation

- **`backmapping`**: Maps filtered ONT reads back to the polished assembly. Useful to identify structural anomalies or coverage issues.
- **`annotation`**: Fast functional annotation with **eggNOG-mapper** for gene content overview.  
  > ⚠️ **Note**: This is not intended to be a comprehensive genome annotation.

### Artifact Detection

Manual curation is necessary if the following patterns appear:

1. Local accumulation of unexpected SNPs  
2. Abrupt coverage drops  
3. Extensive soft/hard read clipping

<p align="center">
  <img src="https://github.com/nicolo-tellini/sunp/blob/main/artifact_eaxample.png" alt="Artifact ONT"/>
</p>

---

This pipeline is modular and flexible, but assumes high-quality data from R10.4 ONT and Illumina PE. Adjustments for other technologies must be made manually.


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
