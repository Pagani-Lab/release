#!/bin/bash

# this script extracts phenotypic data form a list.csv 
# and writes them in a new file.csv.
# this script selects only data from patients younger than 13 yo
# and from the 8 specified sites.


data=/media/DATA1/IIT_17Sep_Tsc2/01_rsfMRI_human_ABIDE1_Lombardo/01_general_information_originally_shared_by_lombardo/ABIDE_I_pheno_data.csv # edit this, this file contains subject's IDs and all other clinical features (age, diagnosis, IQ)

max_age=13

outfile=phenotypic_data_for_covariates.csv

> $outfile

echo "site,ID,diagnosis,age,sex,FIQ,VIP,PIQ,test_IQ" >> $outfile

while read line; do

	site=$(cut -f1 -d, <<< $line)		
	subject=$(cut -f2 -d, <<< $line)
	diagnosis=$(cut -f3 -d, <<< $line)
	age=$(cut -f5 -d, <<< $line)
	sex=$(cut -f6 -d, <<< $line)
	FIQ=$(cut -f9 -d, <<< $line)
	VIP=$(cut -f10 -d, <<< $line)
	PIQ=$(cut -f11 -d, <<< $line)
	test_IQ=$(cut -f12 -d, <<< $line)
	

	if [ "$site" = "KKI" ] || [ "$site" = "NYU" ] || \
	   [ "$site" = "OHSU" ] || [ "$site" = "STANFORD" ] || \
	   [ "$site" = "UCLA_1" ] || [ "$site" = "UCLA_2" ] || \
	   [ "$site" = "UM_1" ] || [ "$site" = "YALE" ]; then

	if (( $(echo "$age < $max_age" | bc -l) )); then

	echo "$site,$subject,$diagnosis,$age,$sex,$FIQ,$VIP,$PIQ,$test_IQ" >> $outfile

	fi 
	fi
		
done < $data



