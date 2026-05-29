#!/bin/bash

# this script adds the diagnosis to ts

# DX_GROUP (column 3): 1=ASD, 2=CTRL
# DSM_IV_TR (column 4): 0=CTRL, 1=ASD, 2=Asperger, 3=PDD-NOS, 4=Asperger or PDD-NOS


data=$PWD/ABIDE_I_pheno_data.csv 
subject_path=$PWD/05_younger_than_13/ # edit this, this folder contains the preprocessed ts

cd $subject_path/

while read line; do

	subject=$(cut -f2 -d, <<< $line)
	diagnosis=$(cut -f3 -d, <<< $line)

	echo $subject $diagnosis

	if (( $(echo "$diagnosis == 1" | bc -l) )); then

		for img in *_00${subject}_*; do mv "$img" "${img/.nii.gz/_ASD.nii.gz}";done

	elif (( $(echo "$diagnosis == 2" | bc -l) )); then

		for img in *_00${subject}_*; do mv "$img" "${img/.nii.gz/_CTR.nii.gz}";done
	
	fi

done < $data

cd ..


