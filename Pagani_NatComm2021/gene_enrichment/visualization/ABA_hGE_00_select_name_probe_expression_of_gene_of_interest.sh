#!/bin/bash

# This pipeline is aimed to plot gene expression (GE) values of the complete 
# normalized microarray datasets of the six human donors of the Allen Brain 
# Atlas (ABA, http://human.brain-map.org/static/download) to a 3D brain. The
# whole pipleine will produce averages across probes of the same gene, averages
# of the same gene across donors, averages across genes for each donor and
# averages across genes and across donors (this last is Pagani et al. NatComm 
# Figure 4D).
# 
# Gene expression data can be downloaded here.
# http://human.brain-map.org/static/download
#
# This is the donor's list
# H0351.1009 = donor12876
# H0351.1012 = donor14380
# H0351.1015 = donor15496
# H0351.1016 = donor15697
# H0351.2001 = donor9861
# H0351.2002 = donor10021
#
# This first script subsets Probes.csv based on your list of genes of interest 
# ($your_gene_list) e.g. genes positively enriched in a separate analysis, and 
# extract the probe_ID and expression values of those genes.
#
# The list of genes is a column vector txt file, and usually is the result of
# previous statistical analysis. In this list, gene names has to be the same used 
# by ABA! 
#
# Folder tree is root	- donor9861_H0351.2001	- normalized_microarray_donor9861	- MicroarrayExpression.csv
#											- Ontology.csv
#											- PACall.csv
#											- Probes.csv
#											- Readme.txt
#											- SampleAnnot.csv
# 					     	- T1_donor9861_H0351.2001.nii.gz		
#			- donor10021_H0351.2002 - normalized_microarray_donor10021
#						- T1_donor10021_H0351.2002.nii.gz
# 
# The output of this script is genes_probes_expressions.txt 
# i.e. a file containing gene_symbol, probe_ID and expression value.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------


your_genelist=/path/your_gene_of_interest.txt
path_donor=/path_to_donorXXX_HXXX.XXX/ # path to folder of the donor of interest originally downloaded from ABA website
donor_name=donor_name # e.g. donor9861_H0351.2001

sed 1d $path_donor/Probes.csv | while read line_Probes; do

	# this selects the column of the gene
	probe_ID=$(cut -f1 -d, <<< $line_Probes)
	gene_symbol=$(cut -f4 -d, <<< $line_Probes)
	
	# this removes quotes from gene symbol	
	gene_symbol=$(sed -e 's/^"//' -e 's/"$//' <<< "$gene_symbol")

	# this compare the genes in your list and the genes in Probes
	# and write probe_ID and gene_symbol in genes_probes.txt
	genelist=`cat $your_genelist`

	for gene in $genelist; do

		if [ "$gene" == "$gene_symbol" ]; then

		echo $gene $probe_ID >> genes_probes.txt

		fi

	done

done


# this creates genes_probes_expressions.txt with probe_ID, gene_symbol and expression values
while read line_genes_probe; do

	gene=$(cut -f1 -d" " <<< $line_genes_probe)
	probe=$(cut -f2 -d" " <<< $line_genes_probe)

	while read line_MicroarrayExpression; do

	probe_MicroarrayExpression=$(cut -f1 -d, <<< $line_MicroarrayExpression)

		if [ "$probe" == "$probe_MicroarrayExpression" ]; then

		echo $probe_MicroarrayExpression

		printf "$gene,$line_MicroarrayExpression\n" >> genes_probes_expressions_${donor_name}.txt

		fi

	done < $path_donor/MicroarrayExpression.csv
	
done < genes_probes.txt

rm genes_probes.txt

exit
