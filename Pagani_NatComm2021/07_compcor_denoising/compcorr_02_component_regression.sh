#!/bin/bash

# This script regresses out the structured noise components 
# extracted by CompCorr
#
# You need to put motion traces and registered ts 
# in the folder to use the script.
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# Autism Center, CMI
# February 2021
# ----------------------------------------


numjobs=7

function regress_nuisance_subject {

    ts=$1
    subject=$(basename $ts .nii.gz) # edit this, registered ts
    noise_components=${subject}_structured_noise.txt # edit this, motion traces

    # convert txt to mat
    Text2Vest $noise_components ${subject}_to_regress.mat

    # Nuisance regression. 
    fsl_regfilt \
	-i $ts \
	-d ${subject}_to_regress.mat \
	-f "1,2,3,4" \
	-o ${subject}_regressed.nii.gz 

    # This cleans the output
    rm ${subject}_to_regress.mat
       
    }
export -f regress_nuisance_subject

# Main code starts here
echo *_MNI152_3mm.nii.gz | tr " " "\n" > subject_list.txt # edit this, registered ts

parallel \
    -j $numjobs \
    regress_nuisance_subject {} \
    < subject_list.txt

