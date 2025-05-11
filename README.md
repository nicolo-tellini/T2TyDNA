# sunp
simplified unified nanopore pipeline aka sunp (Saccharomyces ONT T2T assembly)

# workflow

`initiate` defines and creates necessary directories. `precontig` anticipates the assembly phase, filtering the reads according to specified parameters [default: minimum length 10 kb and 60x coverage]. `contig` and  `contig4` perform de novo assembling with `Flye` and `hifiasm`, respectively. Once assembled, `seqkit` removes contigs shorter than 10 kb while `QUAST` and `BUSCO` assess the raw assembly's quality and completeness. `Polishing` runs the raw assembly polishing according to the following scheme: 
1) one round correction with ONT reads `minimap2-racon`
2) `medaka consensus`
3) one round correction with Illumina reads `bwa-pilon`
`scaffolding2` performs the scaffolding in reference-free mode with `ntLink`.
Centromere identification, sequence reorientation and visual inspection of the alignment against a reference genome.  
`QUAST`, `nucmer` and `BUSCO` assess the final assemblies' quality and completeness. 
Finally, `telofinder` detects the number of terminal (and eventually internal) telomeric regions while `MUM&CO` recovers structural variants from pairwise comparison with a reference genome. 
A summary is generated at the end of the run. This can be used to choose the assembly that best fits the proposal of the project.

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
