#!/bin/bash
#
# This code resmaple the GE map to MNI 1mm to produce 
# high quality visualisations
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

for img in ASD*.nii.gz; do

3dresample \
	-rmode "Li" \
	-master MNI152_T1_1mm_brain.nii.gz \
	-prefix ${img%.nii.gz}_1mm.nii.gz \
	-input $img
done 
