# sunp
simplified unified nanopore pipeline aka sunp (Saccharomyces ONT T2T assembly)

# workflow

`initiate` definies and creates necessary directories. `precontig` anticipates the assemblying phase filtering the reads according to specified parameters [default: minimum length 10 kb and 60X coverage]. `contig`,`contig2`, `contig3` perform de novo assembling with `Flye`, `Canu`, `Smartdenovo` and `hifiasm`, respectively. Once assembled `seqkit` removes contig shorter than 10 kb while `QUAST` and `BUSCO` assess the quality and the completeness of the raw assembly. `polishing` runs the raw assembly polishing according to the following scheme: 
1) one round correction `minimap2-racon`
2) `medaka consensus`
3) one round correction `bwa-pilon`

`scaffolding2` performs the scaffoldig in 2 different ways:
1) reference-free scaffolding with `ntLink`
2) reference-guided scaffolding with `ragtag`

reference-free scaffolding are generally prefered over reference-guided.
`QUAST`,`nucmer` and `BUSCO` assess the quality and the completeness of the final assemblies. 
Finally, `telofinder` detects the number of terminal (and eventually internal) telomeric regions.   
`MUM&CO` recovers structural variants from pairwise comparison with a reference genome. 

A summary is generated at the end of the run. This can be used to choose the assembly that better fit with the proposal of the project.

# Dependecies 
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
