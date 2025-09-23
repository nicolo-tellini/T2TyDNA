#!/bin/bash

set -x

source ./config

cd $tmpdir

## backmapping
assemblies_clean="$inds.medaka.flye.ragtag.fa"
fasta=$assemblies_clean
assembler="flye"

#conda activate minimap2
minimap2 -ax map-ont -t 8 "$basedir/tmp/$fasta" "$seqdir/$inds.fastq.gz" > "$mapdir/$inds.$assembler.ont.sam"
#conda deactivate

#conda activate samtools 
samtools  view -@8 "$mapdir/$inds.$assembler.ont.sam" -o "$mapdir/$inds.$assembler.ont.bam"
samtools sort -l 1 -@8 -o "$mapdir/$inds.$assembler.ont.srt.bam" "$mapdir/$inds.$assembler.ont.bam"
samtools index "$mapdir/$inds.$assembler.ont.srt.bam"
#conda deactivate 
 
cd $mapdir

rm $inds".flye.sam" $inds".flye.bam"

rm $inds.$assembler".ont.sam" $inds.$assembler".ont.bam"
