#!/bin/bash
#
# This script calculates global (long-range) connectivity 
# i.e. mean voxelwise functional Pearson's correlation (non z-transformed) between each 
# voxel and all the others in the brain. 
#
# The folder where you use this script should contains
# preprocessed (smoothed) and ts dcbc.py
#
# this is a modified version that allows each ts to have its own mask
# ------------------------------------------------------------

numjobs=5
path_smoothed_ts=$PWD/05_younger_than_13/ # edit this

function globalconn {
    ts=$1
    mask=${ts%.nii.gz}_GM_mask.nii.gz #edit this
    outdir=06_gbcmaps # edit this

    name=$(basename $ts .nii.gz)
    python -u dcbc_r.py \
        -m $mask \
        -o $outdir/${name}_globalconn.nii.gz \
        $ts
}
export -f globalconn


# Main starts here

mkdir 06_gbcmaps

echo $path_smoothed_ts/*_PP_*3mm.nii.gz | tr " " "\n" > list.txt
parallel \
    -j $numjobs \
    globalconn {} \
    < list.txt
