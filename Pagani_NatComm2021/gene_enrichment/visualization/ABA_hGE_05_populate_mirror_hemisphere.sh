#!/bin/bash
#
# GE data is available for one hemisphere only, this code then
# flips those values to the other hemiphere.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto "
# (2019)
# -----------------------------------------------------------


for map in *.nii.gz; do

	map_name=${map%.nii.gz}

	3dLRflip \
		-X \
		-prefix ${map_name}_flipped.nii.gz \
		$map

	ImageMath 3 \
		${map%_registered_to_MNI152_T1_3mm_brain.nii.gz}_fullbrain_registered_to_MNI152_T1_3mm_brain.nii.gz \
		addtozero \
		$map \
		${map_name}_flipped.nii.gz 

done

rm *_flipped.nii.gz

