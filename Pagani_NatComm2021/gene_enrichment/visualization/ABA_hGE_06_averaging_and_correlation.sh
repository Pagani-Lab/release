#!/bin/bash
#
# This code output a single map where each voxel's value is 
# the average GE across genes of the gene list and across all donors.
# This code finally calculates spatial Pearson's correlation between
# that map and your fMRI map of interest.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

brainmask=/media/DATA1/IIT_17Sep_Tsc2/06_ABA_gene_expression/Mask_ABIDE_85Percent_GM.nii.gz
rsfMRImap=/media/DATA1/IIT_17Sep_Tsc2/06_ABA_gene_expression/01b_rsfMRI_maps_of_interest/seed_based_analysis_covar_site_random_intercept_effect_IQ_age_sex_fixed_effect_inv.nii.gz

gene_list=(CDKN1A CPT1A EGFR EIF4EBP1 ERBB2 FGF2 FKBP8 ITPR2 MAPKAP1 MECP2 MRO PDGFRA PIK3CB PREX2 RALA SLC1A4 TLR4)
donor_list=(T1_donor9861_H0351.2001.nii.gz T1_donor10021_H0351.2002.nii.gz T1_donor12876_H0351.1009.nii.gz T1_donor14380_H0351.1012.nii.gz T1_donor15496_H0351.1015.nii.gz T1_donor15697_H0351.1016.nii.gz)

for map in *_registered_to_MNI152_T1_3mm_brain.nii.gz; do

	map_name=${map%.nii.gz}

	fslmaths \
		$map \
		-bin \
		${map_name}_bin.nii.gz

done


# this creates an avarage for that gene across donors

for gene in "${gene_list[@]}"; do

	3dMean \
		-prefix gene_${gene}_sum.nii.gz \
		-sum *_${gene}*_brain.nii.gz

	3dMean \
		-prefix gene_${gene}_occurrence.nii.gz \
		-sum *${gene}*_bin.nii.gz

	fslmaths \
		gene_${gene}_sum.nii.gz \
		-div \
		gene_${gene}_occurrence.nii.gz \
		gene_${gene}_GE.nii.gz

done


# this creates an avarage for that donor across genes

for donor in "${donor_list[@]}"; do

	3dMean \
		-prefix donor_${donor%.nii.gz}_sum.nii.gz \
		-sum ${donor%.nii.gz}*_brain.nii.gz

	3dMean \
		-prefix donor_${donor%.nii.gz}_occurrence.nii.gz \
		-sum ${donor%.nii.gz}*_bin.nii.gz

	fslmaths \
		donor_${donor%.nii.gz}_sum.nii.gz \
		-div \
		donor_${donor%.nii.gz}_occurrence.nii.gz \
		donor_${donor%.nii.gz}_GE.nii.gz

done


# this creates an average across genes and across donors

3dMean \
	-prefix all_genes_sum.nii.gz \
	-sum *_brain.nii.gz

3dMean \
	-prefix all_genes_occurrence.nii.gz \
	-sum *_bin.nii.gz

fslmaths \
	all_genes_sum.nii.gz \
	-div \
	all_genes_occurrence.nii.gz \
	all_genes_GE.nii.gz


rm *_sum.nii.gz
rm *_bin.nii.gz


# this calulate the spatial correlation between 
# the GE map and a fMRI map

for GE_map in *_GE.nii.gz; do

echo $GE_map

fslcc \
	-m $brainmask \
	--noabs \
	-t -1 \
	$GE_map \
	$rsfMRImap

done
