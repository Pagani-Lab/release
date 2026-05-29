#!/bin/bash
# this extracts the ID and age from file.csv and moves
# ts for subjects younger than 13 years old


data=$PWD/ABIDE_I_pheno_data.csv # edit this, this file contains subject's ID and other clinical features
ts_path=$PWD/04_renamed/ # edit this, this folder contains preprocessed ts

max_age=13 # edit this, maximum age
newdir=05_younger_than_13 # edit this


mkdir $newdir

while read line; do

	subject=$(cut -f2 -d, <<< $line)
	age=$(cut -f5 -d, <<< $line)

	echo $subject $age

	if (( $(echo "$age < $max_age" | bc -l) )); then

	cp $ts_path/*_00${subject}_PP.nii.gz $newdir/
	cp $ts_path/*_00${subject}_PP_fd.txt $newdir/
	
	fi

done < $data

