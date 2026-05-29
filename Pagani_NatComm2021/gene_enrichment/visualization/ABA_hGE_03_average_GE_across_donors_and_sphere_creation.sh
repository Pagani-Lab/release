#!/bin/bash
#
# This code creates the spheres and calculates mean GE values across all donors
#
# https://blog.cogneurostats.com/2014/02/05/advanced-creation-of-rois-in-afni/
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


template=MNI152_T1_3mm_brain.nii.gz
brainmask=Mask_ABIDE_85Percent_GM.nii.gz
radius=6 # edit this 


for gene in T1*.nii.gz; do

	gene_name=${gene%.nii.gz}

	3dmaskdump \
		-nozero \
		-o ${gene_name}_sphere_center.txt \
		$gene

	# number of spheres, not used here
	number_of_spheres=$(wc -l ${gene_name}_sphere_center.txt | awk -F' ' '{print $1}') 
	
	while read sphere_center_line; do	

		x=`echo "$sphere_center_line" | awk -F' ' '{print $1}'`
		y=`echo "$sphere_center_line" | awk -F' ' '{print $2}'`
		z=`echo "$sphere_center_line" | awk -F' ' '{print $3}'`
		
		echo $sphere_center_line > ${x}_${y}_${z}_coordinates_${gene_name}.txt

		3dUndump \
			-prefix ${gene_name}_with_sphere_${x}_${y}_${z}_GE.nii.gz \
			-master $gene \
			-datum float \
			-srad $radius \
			${x}_${y}_${z}_coordinates_${gene_name}.txt

		fslmaths \
			${gene_name}_with_sphere_${x}_${y}_${z}_GE.nii.gz \
			-bin \
			${gene_name}_with_sphere_${x}_${y}_${z}_bin.nii.gz

		rm ${x}_${y}_${z}_coordinates_${gene_name}.txt

	done < ${gene_name}_sphere_center.txt


	# this merges all spheres of one gene in one file
	3dMean \
		-prefix ${gene_name}_with_sphere_GE.nii.gz \
		-sum ${gene_name}_with_sphere_*_GE.nii.gz

	3dMean \
		-prefix ${gene_name}_with_sphere_bin.nii.gz \
		-sum ${gene_name}_with_sphere_*_bin.nii.gz

	fslmaths \
		${gene_name}_with_sphere_GE.nii.gz \
		-div \
		${gene_name}_with_sphere_bin.nii.gz \
		${gene_name}_to_be_plotted.nii.gz

	rm ${gene_name}_sphere_center.txt	
	rm ${gene_name}_with_sphere*GE.nii.gz
	rm ${gene_name}_with_sphere*bin.nii.gz

done





