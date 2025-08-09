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
1. Ensuring **reproducibility** of genome assembly and annotation workflows.
2. Running **new strains** for which both R10.4 are available.
> ⚠️ **Note**: This pipeline is provided as-is. It will **not** be adapted for individual cases.

---

## Workflow

The pipeline consists of multiple sequential modules to generate a T2T genome assembly, polishing, quality control, telomere length estimation, ORFs identification and functional annotation. 
Below is an overview of each step:

### 1. Initialization & Pre-processing

- **`initiate`**: Sets up the directory structure and required files.
- **`precontig`**: Filters long reads before assembly, based on user-defined thresholds  
  *(default: minimum read length = 10 kb,  average read quality 15, target coverage = 50×)*.

### 2. Assembly

- **`contig`**: Performs de novo assembly using **Flye**.
- **`QUAST`** and **`BUSCO`**: Evaluate assembly quality and gene completeness.
- - **`mash`** and **`MUMmer`**

### 3. Intermediate Assessment

- **`assessment_after_contigs`** (**`mash`** and **`MUMmer`**): Aligns the draft assembly to a reference genome using **MUMmer**  
  *(reference genomes aree placed in the `rep/` directory and automatically selected)*.

### 4. Polishing

A three-step polishing process:

- **`minimap2` + `racon`**: One round of correction with ONT reads.
- **`medaka`**: Generates high-quality consensus (one round).
- **`assign_cent`**: Extracts centromere positions from the reference annotation and maps them to the new assembly.
-  **`reorderscaffolds`**: Names and orders contigs based on centromere positions.

> If multiple centromeres are found on the same contig (e.g., `IV_XIII`), this likely indicates an assembly artifact requiring manual inspection.

### 5. Telomere Length Estimation

- **`backmapping`**: Filtered ONT reads are mapped back to the de novo assembled genome.
- **`samtools`**: Extraction reads mapping at the beginning and end of the chromosome (those covering a rage of 20kb)
- **`telofinder`**: Detects telomeric repeats from the reads (Only terminal singnals are mantained).

### 8. Backmapping & Annotation

- **`backmapping`**: Maps filtered ONT reads back to the polished assembly. Useful to identify structural anomalies or coverage issues.
- **`annotation`**: Fast functional annotation with **eggNOG-mapper** for gene content overview.  
  > ⚠️ **Note**: This is not intended to be a comprehensive genome annotation.

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

### Artifact Detection

Manual curation is necessary if the alignmewnt shows the following patterns:

1. Local accumulation of unexpected SNPs  
2. Abrupt coverage drops  
3. Extensive soft/hard read clipping

<p align="center">
  <img src="https://github.com/nicolo-tellini/sunp/blob/main/artifact_eaxample.png" alt="Artifact ONT"/>
</p>

---

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

FASTQs data **must** be gziped and suffixed as sample**.fastq.gz** (ont).
FASTQs are located inside seq dir. 

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
#                                			                      #
# Contact me at nicolo.tellini.2@gmail.com		              #
###########################################################

##########################################################
#		                  USER VARIABLE			                    #
##########################################################

     		 
nt=8 # Number of threads
inds=yS881 # Sample name

```

Run ```runner.sh``` :runner: 

```{bash}
bash runner.sh &
```

## Dependencies

The pipeline relies on a set of established bioinformatics tools. **Conda** is the recommended method for installation.
The installation environment is named **t2tydna**. 

```sh
conda create -n yeast_t2t python=3.10 -y
conda activate yeast_t2t
```

The tools below can be installed as follow:

```sh
conda install -y -c conda-forge -c bioconda \
    filtlong=0.2.1 \
    pytorch=2.3 \
    numpy \
    h5py \
    mappy \
    nanoplot=1.44.1 \
    augustus=3.5.0 \
    gffread=0.12.7 \
    eggnog-mapper=2.1.13 \
    flye=2.9.6 \
    seqkit=2.10.0 \
    quast=5.3.0 \
    busco=5.8.2 \
    minimap2=2.29 \
    racon=1.5.0 \
    medaka=2.0.1 \
    bwa=0.7.19 \
    samtools=1.21 \
    ragtag=2.1.0 \
    mummer4=4.0.1 \
    pybedtools=0.12.0 \
    r-base=4.3 \
    r-essentials \
    r-seqinr \
    r-data.table \
    r-ggplot2 \
    r-viridis \
    r-ggextra \
    pip \
    2>&1 | tee conda_install.log
```

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
| RagTag       | v2.1.0           | `bioconda`           |
| TeloFinder   | *(custom script)*| see `scripts/`       |
| MUMmer4      | v4.0.1             | `bioconda`      |
| Pybedtools       | v0.12.0             | `default`            |
| r-base       | 4.3             | `default`            |
| r-essentials       |              | `default`            |
| pip       |              | `default`            |
