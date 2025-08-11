#/bin/bash 

set -x

source ./config

cd $tmpdir

#conda activate mash

for i in $(ls $basedir/rep/*fa)
do
mash dist $inds".flye.raw.fasta" $i >> $inds".mash" 2> /dev/null
done

#conda deactivate 

sort -k3,3 $inds".mash" > $inds".sort.mash"

rm $inds".mash"

ref_pathfile=$(cat $inds".sort.mash" | cut -f2 | head -1)
gff_pathfile=$(echo $ref_pathfile | sed 's+.fa+.gff3+g')

#conda activate mummer
nucmer -t 10 -p $inds".flye.raw" $inds".flye.raw.fasta" $ref_pathfile
delta-filter -1 $inds".flye.raw.delta" >  $inds".flye.raw.delta_filter"
mummerplot --large --color --png $inds".flye.raw.delta_filter" -p $inds".flye.raw"
#conda deactivate
convert $inds".flye.raw.png" $inds".flye.raw.pdf"

rm *rplot *gp *fplot *.delta *.png *.delta_filter 
