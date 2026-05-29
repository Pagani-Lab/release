#!/bin/bash
# this extracts the ID and age from file.csv and moves
# ts for subjects younger than 13 years old


data=$PWD/clinical_scores.csv # edit this, this file contains subject's ID and other clinical features
ts_path=$PWD/02_subjects_filtered_only_patients/ # edit this, this folder contains preprocessed ts

score=-1 # edit this, maximum age
newdir=03_subjects_filtered_only_patients_with_clinical_scores # edit this


mkdir $newdir

while read line; do

	subject=$(cut -f2 -d, <<< $line)
	ADI_R_SOCIAL_TOTAL_C_restr_repet_ster=$(cut -f12 -d, <<< $line)

	echo $subject $age

	if (( $(echo "$ADI_R_SOCIAL_TOTAL_C_restr_repet_ster > $score" | bc -l) )); then

	cp $ts_path/*${subject}*.nii.gz $newdir/
	
	fi

done < $data

