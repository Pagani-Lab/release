#!/bin/bash
#
# This code calculates mean GE values across probes of the same gene
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------



donor_MRI=/path/to/donor_name.nii.gz # edit this, e.g. T1_donor15697_H0351.1016.nii.gz



donor_MRI_name=${donor_MRI%.nii.gz}

echo ${donor_MRI_name}_* | tr " " "\n" > gene_symbol_probe_ID_list.txt 

while read gene_symbol_probe_ID_list_line; do

	gene_symbol=`echo "$gene_symbol_probe_ID_list_line" | awk -F'_' '{print $4}'`
	probe_ID=`echo "$gene_symbol_probe_ID_list_line" | awk -F'_' '{print $5}'`
	probe_ID=${probe_ID%.nii.gz}

	echo $gene_symbol $probe_ID


	if [ -f "${donor_MRI_name}_${gene_symbol}_mean.nii.gz" ]; then

		echo "${donor_MRI_name}_${gene_symbol}_mean.nii.gz already calculated"

	else 

		echo "${donor_MRI_name}_${gene_symbol}_mean.nii.gz is being calculated"
		
		# this merges all the probes of the same gene in a single nifti file
		# and takes the mean over probes
		fslmerge \
			-t 4d.nii.gz \
			${donor_MRI_name}_${gene_symbol}_*.nii.gz

		fslmaths \
			4d.nii.gz \
			-Tmean \
			${donor_MRI_name}_${gene_symbol}_mean.nii.gz

		rm 4d.nii.gz

	fi

done < gene_symbol_probe_ID_list.txt
