#!/bin/bash

# This code preprocesses BOLD fMRI timeseries as described in Patel et al.                
# One of the main reasons why you may want to use this code is that speedyppX.py 
# allows to carry out wavelet despiking.
#    					   
# This code takes as inputs rest.nii.gz and mprage.nii.gz and outputs 
# a preprocessed timeseries pp.nii.gz plus head motion measurments.
#						    
# Make sure you have afni, fsl, matlab, python2 and python3 installed.
# afni version must be later than 2017 - for example afni Titus is ok. 
# Old afni versions use @align_centers that is not compatible with this 
# code - trust me you don't want to get to the bottom of this :)  			    	   
#						   
# For Matlab you also need 
# 	- the Brain Wavelet toolbox (www.brainwavelet.org)   
#   	- the fMRI Signal Preprocessing Toolbox (not sure you actually need it)          
#
# Importantly, the folder of the templates is hardcoded in line 202 of speedyppX.py,
# edit this before running the code. Eventually the non skull-stripped MNI 3mm template
# is the reference space that worked the best to allign 16p11.2 scans (in about 5
# minutes per scan on a workstation). In general use the version of speedyppX.py that
# has been edited by Marco (as that works for sure)
#
# Before running the analysis you have to point speedyppX to WaveletDespiking toolbox 
# and set the path of WaveletDespiking toolbox in matlab. As most likely 
# you are not sudo of your workstation, follow these instructions to put a startup.m 
# file in the $userpath directory (for example:/home/imaging/Documents/MATLAB/) 
# where you specify where the location of the pathdef.m, as described here:
# https://it.mathworks.com/matlabcentral/answers/102037-how-can-i-move-the-pathdef-m-file-from-its-default-location-to-another-location-in-matlab-8-1-r20 - use the matlab button to to set the desired paths, create your 
# personal pathdef.m and save it in your preferred location.
#
# The recommended folder tree is:
#
# root	--00_code		--templates
# 				--wavelet_despiking
#				--dvars_Se.py
#				--fd.py
#				--pathdef.m
#				--plot_fd_dvars.py
#				--speedyppX.py
#	--01_original_data
#	--02_dicom
#	--03_extracted		--subj01	--mprage.nii.gz
#						--rest.nii.gz
#				--subj02	--mprage.nii.gz
#						--rest.nii.gz
#	--04_preprocessed (output folder)
#
# This code has been originally shared by Mike Lombardo in the context 
# of the NIH 22q11.2 study
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# March 2021
# ----------------------------------------


# define paths

# path to study root
rootpath=/media/DATA1/22q11_human/

# path to extacted ts
tspath=/media/DATA1/22q11_human/03_extracted_Trio/

# path to preprocessed ts
ppts_path=/media/DATA1/22q11_human/04_pp_Trio/

# path to speedyppX
speedy_path=/media/DATA1/22q11_human/00b_code_marco_preprocessing_22q11.2/speedyppX.py

# path to fd.py 
fd_path=/media/DATA1/22q11_human/00b_code_marco_preprocessing_22q11.2/fd.py

# path to dvars_se.py
dvars_path=/media/DATA1/22q11_human/00b_code_marco_preprocessing_22q11.2/dvars_se.py

# path to plot_fd_dvars.py custom MVL script
plot_fd_dvars_path=/media/DATA1/22q11_human/00b_code_marco_preprocessing_22q11.2/plot_fd_dvars.py

# number of initial volumes to remove
tmin=8

# set TR
TR=2

# number of CPU for AFNI
export OMP_NUM_THREADS=8


# copy extracted rsfMRI and mprage scans in a new working directory
cd $rootpath
mkdir $ppts_path
cp -r $tspath/* $ppts_path/

# create the list of subjects 
sublist=$(echo $ppts_path/* | tr " " "\n") 


for subid in $sublist; do

	cd $subid
        	
	# cut volumes with fslroi, output name is Erest.nii.gz
	fslroi rest.nii.gz Erest.nii.gz $tmin -1
	rm rest.nii.gz

	# Make sure -space field in the header is set to ORIG
	3drefit -space ORIG mprage.nii.gz
	3drefit -space ORIG Erest.nii.gz
	
	# edit TR
	3drefit -TR $TR Erest.nii.gz
	
	# make sure orientation is LPI for Erest.nii.gz
	fslorient -getorient Erest.nii.gz
	fslorient -forceradiological Erest.nii.gz
	
	# make sure orientation is LPI for anatomical.nii.gz
	fslorient -getorient mprage.nii.gz
	fslorient -forceradiological mprage.nii.gz
	
	# carry out preprocessing with speedyppX.py
	python2 $speedy_path \
			-d Erest.nii.gz \
			-a mprage.nii.gz \
			-f 6mm \
			-o \
			--coreg_cfun=lpc+ \
			--betmask \
			--ss=MNI152 \
			--align_ss \
			--qwarp \
			--rmot \
			--rmotd \
			--keep_means \
			--wds \
			--threshold=10 \
			--SP \
			--OVERWRITE

	# compute framewise displacement with summary statistics
	python3 $fd_path -d Erest_motion.1D

	# cd into spp.rest
	cd spp.Erest

	# compute DVARS with summary statistics
	python3 $dvars_path -d Erest_sm.nii.gz
	python3 $dvars_path -d Erest_noise.nii.gz
	python3 $dvars_path -d Erest_wds.nii.gz
	
	cd $subid
	mkdir plots

	# Copy paste fd and dvars txt files into plots
	mv Erest_motion_fd.txt plots
    	mv spp.Erest/Erest_sm_dvars.txt plots
    	mv spp.Erest/Erest_noise_dvars.txt plots
    	mv spp.Erest/Erest_wds_dvars.txt plots
    	
	# cd into $plotspath
        cd plots

	# Format arguments for plot_fd_dvars.py
    	FD=Erest_motion_fd.txt
    	DVARSSM=Erest_sm_dvars.txt
    	DVARSNOISE=Erest_noise_dvars.txt
    	DVARSWDS=Erest_wds_dvars.txt
    	plotpyoptions="--fd $FD --dvars_sm $DVARSSM --dvars_noise $DVARSNOISE --dvars_wds $DVARSWDS"

    	# Run plot_fd_dvars.py
    	python $plot_fd_dvars_path $plotpyoptions --pdf2save motion_plot.pdf

done

