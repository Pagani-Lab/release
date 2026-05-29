#!/bin/bash
#
# This code writes the gene expression value of each probe in a nifti file.
#
# Before using this code, remember to remove all non-separator commas 
# from CSV annotated file and create a SampleAnnot_wc.csv (wc=without comma)
#
# The output looks like:
#  - T1_donor12876_CDKN1A_1058358.nii.gz
#  - T1_donor12876_CDKN1A_1058359.nii.gz
#  - T1_donor12876_CPT1A_1030997.nii.gz
# 
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------



donor_MRI=/path/to/donor_name.nii.gz # edit this, e.g. T1_donor15697_H0351.1016.nii.gz
path_donor=/path_to_donorXXX_HXXX.XXX/ # edit this, e.g. path to folder of the donor of interest originally downloaded from ABA website


donor_MRI_name=${donor_MRI%.nii.gz}
donor_MRI_name=${donor_MRI_name#T1_}


while read line_genes_probes_expressions; do

	# this extracts gene symbol
	gene_symbol=`echo "$line_genes_probes_expressions" | awk -F',' '{print $1}'`

	# this extracts probe_ID
	probe_ID=`echo "$line_genes_probes_expressions" | awk -F',' '{print $2}'`

	# this writes GE values in a column vector
	echo $line_genes_probes_expressions | cut -d "," -f 2- | tr , '\n' > gene_${gene_symbol}_probe_${probe_ID}_expressions.txt

	# this pastes the column vector to SampleAnnot_wc.csv
	paste -d, $path_donor/SampleAnnot_wc.csv gene_${gene_symbol}_probe_${probe_ID}_expressions.txt > SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.csv

	# remove first line 
	tail -n +2 SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.csv > del_SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.csv

	# extracts coordinates and gene expression values
	cut -d, -f 8,9,10,14 del_SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.csv > SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.txt

	# removes commas
	tr ',' ' ' <SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions.txt > SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions_wc.txt 

	# creates nifti files
	3dUndump \
		-prefix T1_${donor_MRI_name}_${gene_symbol}_${probe_ID}.nii.gz \
		-master $donor_MRI \
		-datum float \
		SampleAnnot_wc_gene_${gene_symbol}_probe_${probe_ID}_expressions_wc.txt

	rm gene_${gene_symbol}_probe_${probe_ID}_expressions.txt

done < genes_probes_expressions_${donor_MRI_name}.txt

rm del_SampleAnnot_wc*
rm SampleAnnot_wc*

exit

