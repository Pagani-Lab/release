#!/bin/bash
#
# This script calculates global (long-range) connectivity i.e. mean voxelwise 
# functional correlation between each node of the connectivity matrix and all 
# the others in the brain. This metric is also known as weighted degree centrality 
# as in Cole et al. NImage2009:
#
# https://www.sciencedirect.com/science/article/pii/S1053811909011616
#
# This code allows to calculate global connectivity at the region level, 
# then of course you need a reference parcellated atlas. 
# 
# Practical info:
#
#   1) use bash human_rsfMRI_01_rsfmri_global_connectivity_regionwise.sh 
#      to calculate global connectivity for each subject of the study.
# 
#   2) then use 02_group_two_sample.sh to calculate one 
#      sample and two sample t-tests - this is based on afni.
# 
#   3) you may want to leave the dcbc_voxelwise_and_regionwise.py unchanged. 
#      This is the code that does the actual calculations then do remember 
#      to copy and paste it in your working directory.
#
# The calculation is fully automatized and relatively fast, 
# all you need to do is to edit this bash script and provide:
#
#   - the number of CPU ("numjobs") you want to use - this is 
#     the number of subjects you want to analyze simultaneously 
#     (you need to have this installed https://www.gnu.org/software/parallel/)
# 
#   - the path of the folder of your preprocessed data ("path_ts").
# 
#   - the brainmask you use for the study with full path ("mask.nii.gz"), this
#     could be a binarised version of the atlas for consistency, especially if
#     the atlas covers gray matter
#
#   - the parcellated_atlas.nii.gz, for example the Schaefer2018_400Parcels, 
#     where I also added OHA subcortex and cerebellum from FSL. 
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


numjobs=4

path_ts=/data3/autism_center/projects/marco/00_preprocessed_ABIDE_data/ABIDEI/output/pipeline_cpac_1.6.2_nuisance/*/functional_to_standard/_scan_rest_run-1/_selector_aC-CSF+WM-2mm-DPC5_M-SDB_P-2_BP-B0.01-T0.1/ # edit this

function globalconn {

    path_ts=/data3/autism_center/projects/marco/00_preprocessed_ABIDE_data/ABIDEI/output/pipeline_cpac_1.6.2_nuisance/*/functional_to_standard/_scan_rest_run-1/_selector_aC-CSF+WM-2mm-DPC5_M-SDB_P-2_BP-B0.01-T0.1/  # edit this
    
    atlas=Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm.nii.gz # edit this

    ts=$1

    echo $ts

    name=$(basename $ts .nii.gz)
    
    echo $name
    
    sub_id=$(echo $ts | cut -d/ -f10)
    
    echo $sub_id

    mask=Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.nii.gz

    outdir=01_gbcmaps_regionwise # edit this

    python dcbc_voxelwise_and_regionwise.py \
		 	-i $ts \
			-m $mask \
			-a $atlas \
			-o ${outdir}/${sub_id}_globalconn_regionwise.nii.gz 
}
export -f globalconn


# Main starts here

mkdir 01_gbcmaps_regionwise # edit this

echo ${path_ts}/*.nii.gz | tr " " "\n" > list.txt # edit this
parallel \
    -j $numjobs \
    globalconn {} \
    < list.txt
