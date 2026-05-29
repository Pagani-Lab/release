#!/bin/bash
#
# This script calculates global (long-range) connectivity i.e. mean voxelwise 
# functional correlation between each node of the connectivity matrix and all 
# the others in the brain. This metric is also known as weighted degree centrality 
# as in Cole et al. NImage2009:
#
# https://www.sciencedirect.com/science/article/pii/S1053811909011616
#
# This code allows to calculate global connectivity at the voxel level. 
# To speed up calculations this code resamples the timeseries to 4mm isotropic.
# 
# Practical info:
#
#   1) use bash human_rsfMRI_01_rsfmri_global_connectivity_regionwise_with_resampling.sh 
#      to calculate global connectivity for each subject of the study.
# 
#   2) then use 02_group_two_sample.sh to calculate one 
#      sample and two sample t-tests - this is based on afni.
# 
#   3) you may want to leave the dcbc_voxelwise_and_regionwise.py unchanged. 
#      This is the code that does the actual calculations then do remember 
#      to copy and paste it in your working directory.
#
# The calculation is fully automatized and fast, 
# all you need to do is to edit this bash script and provide:
#
#   - the number of CPU ("numjobs") you want to use - this is 
#     the number of subjects you want to analyze simultaneously 
#     (you need to have this installed https://www.gnu.org/software/parallel/)
# 
#   - the path of the folder of your preprocessed data ("path_ts").
# 
#   - the brainmask you use for the study with full path ("brainmask.nii.gz"),
#     this could be a binarised version of the atlas for consistency, especially if
#     the atlas covers gray matter
#
# To make you life super-easy, I added "# edit_this" here and there, 
# then you know where to edit your paths. this code was originally
# written by Adam and then edited by Lombardo and then by Marco. 
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# April 2021
# ----------------------------------------


numjobs=2

path_ts=/media/DATA1/22q11_human/06_resampled_to_MNI/ # edit this

function globalconn {

    brainmask=/media/DATA1/22q11_human/Schaefer2018_400Parcels_17Networks_order_plus_subcortex_and_cerebellum_FSLMNI152_3mm_bin.nii.gz # edit this

    outdir=07_gbcmaps_voxelwise # edit this

    ts=$1

    name=$(basename $ts .nii.gz)
    
    echo $name
       
    # this calculates global connectivity
    python dcbc_voxelwise_and_regionwise.py \
		 	-i $ts \
			-m $brainmask \
			-o ${outdir}/${name}_globalconn_voxelwise.nii.gz
    
}
export -f globalconn

# Main starts here
mkdir 07_gbcmaps_voxelwise # edit this

echo ${path_ts}/*.nii.gz | tr " " "\n" > list.txt # edit this
parallel \
    -j $numjobs \
    globalconn {} \
    < list.txt
