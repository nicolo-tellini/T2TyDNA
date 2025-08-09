# T2TyDNA
Telomere-to-Telomere (T2T) Yeast De Novo Assembly

[![Licence](https://img.shields.io/github/license/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/sunp/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/nicolo-tellini/sunp?style=plastic)](https://github.com/nicolo-tellini/sunp/releases)
[![commit](https://img.shields.io/github/last-commit/nicolo-tellini/sunp?color=yellow&style=plastic)](https://github.com/nicolo-tellini/sunp/graphs/commit-activity)

## Description
This pipeline is designed for assemblies using **Oxford Nanopore R10.4 high-quality reads**.  
If you are working with older Nanopore chemistries, you will need to modify the workflow accordingly. 
These use cases are **not supported** by default.

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

## Dependencies

The pipeline relies on a set of established bioinformatics tools. **Conda** is the recommended method for installation, ensuring reproducibility and ease of dependency management.

Below is the list of required tools and their tested versions:

| Tool         | Version         | Installation Source |
|--------------|------------------|----------------------|
| Filtlong     | v0.2.1           | `bioconda`           |
| Python       | v3.10             | `default`            |
| Pytorch       | v2.3             | `default`            |
| numpy       |              | `default`            |
| h5py       |              | `default`            |
| mappy       |              | `default`            |
| NanoPlot     | v1.44.1          | `bioconda`           |
| Augustus       | v3.5.0             | `bioconda`            |
| gffread       | v0.12.7             | `bioconda`            |
| Eggnog-mapper       | v2.1.13             | `bioconda`            |
| Flye         | v2.9.6     | `bioconda`           |
| seqkit       | v2.10.0          | `bioconda`           |
| QUAST        | v5.3.0           | `bioconda`           |
| BUSCO        | v5.8.2           | `bioconda`           |
| minimap2     | v2.29      | `bioconda`           |
| racon        | v1.5.0           | `bioconda`           |
| medaka       | v2.0.1           | `bioconda`           |
| BWA          | v0.7.19    | `bioconda`           |
| Samtools     | v1.21            | `bioconda`           |
| Pilon        | v1.24            | `bioconda`           |
| RagTag       | v2.1.0           | `bioconda`           |
| TeloFinder   | *(custom script)*| see `scripts/`       |
| ntLink       | v1.3.11          | `bioconda`           |
| MUMmer4      | v4.0.1             | `bioconda`      |
| Hifiasm      | v0.25.0     | `bioconda`           |
| Pybedtools       | v0.12.0             | `default`            |
| r-base       | 4.3             | `default`            |
| r-essentials       |              | `default`            |
| pip       |              | `default`            |

### Recommended Environment

We suggest creating a dedicated conda environment:

```bash
conda create -n sunp_env python=3.10
conda activate sunp_env

# Install dependencies
conda install -c bioconda -c conda-forge \
    filtlong nanoplot flye seqkit quast busco minimap2 racon medaka \
    bwa samtools pilon ragtag ntlink hifiasm
```

<details> <summary>📦 <strong>R Package Dependencies</strong> (click to expand)</summary>
 
- seqinr
- data.table
- ggplot2
- viridis
- ggExtra
