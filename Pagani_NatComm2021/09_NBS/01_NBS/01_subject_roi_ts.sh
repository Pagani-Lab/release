#!/bin/bash
#
# This script extracts the spatial mean timeseries of a set of rois 
# for all mice and creates mouse.txt containing the timeseries values

path_ts=$PWD/subjects/ #edit this
path_rois=$PWD/lowres_rois/ #edit this

numjobs=8

function extract_roi_ts {
    ts=$1
    roilist=$2

    name=$(basename $ts .nii.gz)

    while read -r roi;
    do
        if [ ! -f ${name}_ts.txt ]
        then 
            # First ROI 
            fslmeants -i $ts -m $roi \
                | grep -v '^$' \
                | cut -f1 -d' ' \
                > ${name}_ts.txt
        else
            # Other ROI's
            fslmeants -i $ts -m $roi \
                | grep -v '^$' \
                | cut -f1 -d' ' \
                | paste -d' ' ${name}_ts.txt - \
                > ${name}_ts_temp.txt
            mv ${name}_ts_temp.txt ${name}_ts.txt
        fi
    done < roilist.txt
}
export -f extract_roi_ts


# Main starts here

echo $path_ts/ag*.nii.gz | tr " " "\n" > tslist.txt

echo $path_rois/*.nii.gz | tr " " "\n" > roilist.txt

cat tslist.txt | parallel \
    -j $numjobs \
    extract_roi_ts {}
