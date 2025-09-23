#!/bin/bash

set -x

source ./config

ref_pathfile=$(cat $tmpdir/$inds".sort.mash" | cut -f2 | head -1)

cd $tmpdir

ragtag.py scaffold $ref_pathfile $tmpdir/$inds.medaka.flye.final.fasta

ln -s $tmpdir/ragtag_output/ragtag.scaffold.fasta $tmpdir/$inds.medaka.flye.ragtag.fa

sed -i 's+_RagTag++g' $tmpdir/$inds.medaka.flye.ragtag.fa

sed -i 's+chr++g' $tmpdir/$inds.medaka.flye.ragtag.fa
