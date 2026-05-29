#!/bin/bash
#
# This code registers T1 scans and GE maps of each donor to MNI space
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto "
# (2019)
# -----------------------------------------------------------

template=MNI152_T1_3mm_brain.nii.gz # edit this
brainmask=Mask_ABIDE_85Percent_GM.nii.gz # edit this
gene_expression_nifti_path=/media/DATA1/IIT_17Sep_Tsc2/06_ABA_gene_expression/04_donors_in_the_same_MRI_space_prova/mean_to_be_plotted/ # edit this


donor_list=(T1_donor9861_H0351.2001.nii.gz T1_donor10021_H0351.2002.nii.gz T1_donor12876_H0351.1009.nii.gz T1_donor14380_H0351.1012.nii.gz T1_donor15496_H0351.1015.nii.gz T1_donor15697_H0351.1016.nii.gz)


for donor in "${donor_list[@]}"; do

	donor_name=$(basename $donor .nii.gz)	

	antsRegistration \
			-d 3 \
			-r [${template},${donor},1] \
			-o ${donor_name}_ \
			-m CC[${template},${donor},1,5] \
			-t Affine[0.25] \
			-c 100x50x10 \
			-s 5x3x1 \
			-f 5x3x1 \
			-m CC[${template},${donor},1,5] \
			-t SyN[0.25,5,1] \
			-c 100x50x10 \
			-s 5x3x1 \
			-f 5x3x1

	WarpImageMultiTransform \
			3 \
			$donor \
			${donor_name}_registered_to_${template} \
			-R ${template} \
			${donor_name}_1Warp.nii.gz \
			${donor_name}_0GenericAffine.mat 


	for gene_expression in $gene_expression_nifti_path/${donor_name}*; do

		gene_expression_name=${gene_expression%_mean_to_be_plotted.nii.gz}

		echo $gene_expression_name

		antsApplyTransforms \
			-d 3 \
			-e 0 \
			-i $gene_expression \
			-o ${gene_expression_name}_registered_to_${template} \
			-r $template \
			-n MultiLabel \
			-t ${donor_name}_1Warp.nii.gz \
			${donor_name}_0GenericAffine.mat

		fslmaths \
			${gene_expression_name}_registered_to_${template} \
			-mul \
			$brainmask \
			${gene_expression_name}_registered_to_${template}		
		
	done

done
exit



