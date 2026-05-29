#!/bin/bash
# this extracts the ID and age from file.csv and moves
# ts for subjects younger than 13 years old


data=/media/DATA1/22q11_human/phenotyping_info.csv # edit this, this file contains subject's ID and other clinical features
ts_path=/media/DATA1/22q11_human/07_gbcmaps_voxelwise/02_voxelwise_with_diagnosis/ # edit this, this folder contains preprocessed ts

max_age=13 # edit this, maximum age

newdir=/media/DATA1/22q11_human/07_gbcmaps_voxelwise/03_voxelwise_with_diagnosis_younger_than_13/ # edit this


mkdir $newdir

while read line; do

	subject=$(cut -f3 -d, <<< $line)
	
	age=$(cut -f8 -d, <<< $line)

	echo $subject $age

	if (( $(echo "$age < $max_age" | bc -l) )); then

	cp $ts_path/*${subject}*.nii.gz $newdir/

	fi

done < $data

