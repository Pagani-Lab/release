#!/bin/bash

# this script adds the diagnosis to ts

pheno_info=/media/DATA1/22q11_human/phenotyping_info.csv

subject_path=/media/DATA1/22q11_human/07_gbcmaps_voxelwise/01_voxelwise/ # edit this, this folder contains the preprocessed ts

output_path=/media/DATA1/22q11_human/07_gbcmaps_voxelwise/02_voxelwise_with_diagnosis/

mkdir $output_path

cd $subject_path/

while read line; do

	subject=$(cut -f3 -d, <<< $line)
	diagnosis=$(cut -f6 -d, <<< $line)

	echo $subject $diagnosis

	if (( $(echo "$diagnosis == 1" | bc -l) )); then

		for img in *${subject}*; do 
			cp "$img" $output_path/"${img/.nii.gz/_ASD.nii.gz}"; 
		done

	elif (( $(echo "$diagnosis == 0" | bc -l) )); then

		for img in *${subject}*; do 
			cp "$img" $output_path/"${img/.nii.gz/_CTR.nii.gz}";
		done
	
	fi

done < $pheno_info

cd ..


