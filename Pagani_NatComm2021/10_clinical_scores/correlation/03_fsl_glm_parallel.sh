#!bin/bash
#
# This script allows to run multiple fsl_glm in parallel
# for multiple 4d_merged, design matrix and contrast matrix files
# 
# This script is for correlations and t-tests between groups, depending on the appropriate contrast.con matrix
#
# Use the script in the folder containing 4d_merged, design matrix, contrast matrix and mask files
# 4dmerged.nii.gz must contain the string 4d in the filename
#
# Script edited by Marco Pagani
# November 2014
# CNCS @ CIMEC

merged4d_list=$(ls 4d*.nii.gz)
design_matrix_list=$(ls *.mat)
contrast_matrix_list=$(ls *.con)
mask=$(ls $PWD/Mask*)

for merged4d in $merged4d_list ; do
for design_matrix in $design_matrix_list ; do
for contrast_matrix in $contrast_matrix_list ; do

	#use this for correlations
	nohup fsl_glm \
		-i $merged4d \
		-o ${merged4d%.nii.gz}_${design_matrix%.mat}_${contrast_matrix%.con}_betas \
		-d $design_matrix \
		-c $contrast_matrix \
		-m $mask \
		--out_t=${merged4d%.nii.gz}_${design_matrix%.mat}_${contrast_matrix%.con}_t.nii.gz \
		--out_p=${merged4d%.nii.gz}_${design_matrix%.mat}_${contrast_matrix%.con}_p_uncorr.nii.gz \
		--demean \
		--des_norm \
		--dat_norm &

		
NPROC=$(($NPROC+1))
if [ "$NPROC" -ge 7 ]; then
wait
NPROC=0
fi

done
done
done


