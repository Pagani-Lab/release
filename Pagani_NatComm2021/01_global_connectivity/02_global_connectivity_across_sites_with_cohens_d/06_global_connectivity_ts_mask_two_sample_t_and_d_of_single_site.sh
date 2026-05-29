#!/bin/bash

# This script performs unpaired t-test and cohen's d of global or local connectivity maps. 
# Use this script after seed_subjects_correlation_maps.sh
# groupA and groupB are the group names contained in the filenames
#
# Here is the formula I used to convert from t-to-d i.e. d=2t/sqrt(df)
# https://www.soph.uab.edu/sites/edu.ssg/files/People/MBeasley/Courses/EffectSizeConversion.pdf

groupA=ASD # edit this
groupB=CTR # edit this

connectivity_maps_path=$PWD/06_gbcmaps/ # edit this, path of single subject connectivity maps
two_sample=$PWD/07b_t-test_and_cohens_d_single_site/

mkdir $two_sample

sites=(KKI NYU Oregon Stanford UCLA_1 UCLA_2 UM_1 Yale_scans)

for site in "${sites[@]}"; do

    3dttest++ \
        -setA $connectivity_maps_path/${site}_*_${groupA}_*.nii.gz \
        -setB $connectivity_maps_path/${site}_*_${groupB}_*.nii.gz \
        -prefix $two_sample/${site}_stats.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[0]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupA}_vs_${groupB}_group_mean_diff.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[1]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupA}_vs_${groupB}_group_Tstat.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[2]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupA}_mean.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[3]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupA}_Tstat.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[4]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupB}_mean.nii.gz

    3dcalc \
        -a $two_sample/${site}_stats.nii.gz"[5]" \
        -expr "a" \
        -prefix $two_sample/${site}_stats_${groupB}_Tstat.nii.gz



    # cohen's d calculation

    sample_size=$(echo $connectivity_maps_path/${site}* | tr " " "\n" | wc -l)
    df=$(echo $sample_size - 2 | bc )

    3dcalc \
        -a $two_sample/${site}_stats_${groupA}_vs_${groupB}_group_Tstat.nii.gz \
	-expr "(2*a/sqrt($df))" \
        -prefix $two_sample/${site}_stats_${groupA}_vs_${groupB}_group_cohens_d.nii.gz

    rm $two_sample/${site}_stats.nii.gz

done













