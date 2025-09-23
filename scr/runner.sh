#!/bin/bash 

#!/usr/bin/env bash

# ==============================================================
# DONATELO Project — Runner Script
# Created: 2025-01-02
# Last Updated: 2025-09-23
# ==============================================================

# Purpose
# -------
# Estimate telomere length distribution in the context of a dedicated
# experimental setup.

# Assumptions
# -----------
# 1. No major structural rearrangements occur during the experiment.
#    Scaffolding is performed with RagTag against the parental/reference genome.
# 2. Telofinder is run directly on sequencing reads, not on the assembly.

# Notes
# -----
# - If the parental genome is unavailable, use the closest genetically
#   related and collinear genome as reference.
# - The chosen reference assembly must be placed in the `rep/` directory.
# - A collection of reference genomes is available at:
#   https://www.evomicslab.org/db/ScRAPdb/download/
# ==============================================================

set -x 

source ./config

/usr/bin/time -v bash "$basedir/scr/initialize.sh"

/usr/bin/time -v bash "$basedir/scr/precontig.sh" >  "$basedir/log/precontig.log" 2> "$basedir/log/precontig.err"

/usr/bin/time -v Rscript "$basedir/scr/nanoplot_plot.r" "$basedir" "$inds" > "$basedir/log/nanoplot_plot.log" 2> "$basedir/log/nanoplot_plot.err"

/usr/bin/time -v bash "$basedir/scr/contig.sh" $ont_type $genome_size > "$basedir/log/contig.log" 2> "$basedir/log/contig.err"

/usr/bin/time -v bash "$basedir/scr/polishing.sh" $rounds >  "$basedir/log/polishing.log" 2> "$basedir/log/polishing.err"

/usr/bin/time -v bash "$basedir/scr/mash.sh" >  "$basedir/log/mash.log" 2> "$basedir/log/mash.err"

/usr/bin/time -v bash "$basedir/scr/ragtag.sh" >  "$basedir/log/ragtag.log" 2> "$basedir/log/ragtag.err"

/usr/bin/time -v bash "$basedir/scr/backmap.sh" >  "$basedir/log/backmap.log" 2> "$basedir/log/backmap.err"

/usr/bin/time -v bash "$basedir/scr/telomer_dist.sh" >  "$basedir/log/telomer_dist.log" 2> "$basedir/log/telomer_dist.err"

/usr/bin/time -v Rscript "$basedir/scr/telomer_dist_plot.r" "$telodir" "$inds" > "$basedir/log/telomer_dist_plot.log" 2> "$basedir/log/telomer_dist_plot.err"
