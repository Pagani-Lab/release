#
# This R code calculates voxelwise maps of the interaction 
# term of a two-way ANOVA. Examples of the two independent 
# variables are diagnosis and sex and this information has
# be written in the phenotypic_data_MRC.csv. In more practical
# terms, this is the linear model you fit for each voxel:
#
# lm(BOLD ~ diagnosis + sex + diagnosis:sex) 
# 
# and the output is a voxelwise brainmaps, where you have 
# t-score of diagnosis:sex in each voxel.  
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# December 2020
# ----------------------------------------


# this loads the required libraries
library(oro.nifti)
library(robumeta)
library(rowr)


# edit this, CAP number
CAP_number <- 'CAP_1'


# edit this, this loads a csv file containing scan's IDs 
# and the two independent variables. this csv file must 
# contain all and only subjects of interesr for your analysis 
# (of which you have fMRI ts) or the code will not work.
subjectdata_f <- 'phenotypic_data_MRC.csv'
subjectdata <- read.csv(subjectdata_f)


# edit this, this recodes the subjectdata to match filenames.nii.gz.
# this will be used to create the list of subjects to be loaded.
subjectdata$diagnosis_name[subjectdata$diagnosis=="1"] <- "AD"
subjectdata$diagnosis_name[subjectdata$diagnosis=="0"] <- "TD"
subjectdata$sex_name[subjectdata$sex=="1"] <- "M"
subjectdata$sex_name[subjectdata$sex=="0"] <- "F"


# this loads the binary brainmask, edit with the path
mask_f <- 'tcorr05_2level_0042_resampled_to_MNI_brainmask.nii.gz'
mask <- readNIfTI(mask_f) > 0 


# this creates the output directory
outdir_main = 'sex_diagnosis_interaction'
if (!file.exists(outdir_main)) {
	dir.create(outdir_main)
}


# this creates create.map.path, that is a function that generates
# a list of path/maps.nii.gz based on information contained in 
# subjectdata
create.map.path <- function(subject) {
 
	measuremap_f <- paste("/media/DATA1/MRC_caps_autism/07_sex_diagnosis_interaction/k_8/", 
			subjectdata$ID,
			'_LG_Erest_mask_',
			subjectdata$diagnosis_name,
			'_',	
 			subjectdata$sex_name,
               		"_resampled_filtered_",
			CAP_number,
			".nii.gz", sep="")

  return(measuremap_f)
}


# this creates the subjectdata_list
subjectdata_list<-create.map.path(subjectdata)


# this loads all the path/maps.nii.gz for each line of subjectdata_list 
# by using readNifTI based on the subjectdata_list.
measure <- t(sapply(subjectdata_list, function(x) {
  readNIfTI(x)[mask]
}))




# this is the actual GLM fitting with sex, diagnosis and sex*diagnosis as covariates
outdir_cap <- paste(outdir_main, '/', CAP_number, '/', sep="")

if (!file.exists(outdir_cap)) {
	dir.create(outdir_cap)

	# this calculates the full model, i.e. x ~ diagnosis + sex + diagnosis:sex
	full_model <- apply(measure, 2, function(x) {
	summary(lm(x ~ subjectdata$diagnosis + subjectdata$sex + subjectdata$diagnosis:subjectdata$sex))
    	})

	# this saves the t-values of diagnosis:sex interaction
    	tvals_interaction <- lapply(full_model, function (x) {
      	x$coefficients['subjectdata$diagnosis:subjectdata$sex', 3]
    	})
	
	# this saves the p-values of diagnosis:sex interaction
    	pvals_interaction <- lapply(full_model, function(x) {
      	-log10(x$coefficients['subjectdata$diagnosis:subjectdata$sex', 4])
    	})
	
        # this saves the t-values and p-values in nifti format
    	tmap_interaction <- mask
    	tmap_interaction@.Data[mask] <- unlist(tvals_interaction)
	
    	pmap_interaction <- mask
    	pmap_interaction@.Data[mask] <- unlist(pvals_interaction)

	tmap_name <- paste('tmap_sex_diagnosis_interaction', '_', CAP_number, sep="")
	pmap_name <- paste('pmap_sex_diagnosis_interaction', '_', CAP_number, sep="")
	
    	writeNIfTI(tmap_interaction, file.path(outdir_cap, tmap_name))
    	writeNIfTI(pmap_interaction, file.path(outdir_cap, pmap_name))
}
