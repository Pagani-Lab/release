# Web resources
# https://www.alexejgossmann.com/MRI_viz/
# https://stackoverflow.com/questions/45327217/r-squared-of-lmer-model-fit
#
# Linear Mixed Models
# https://cran.r-project.org/web/packages/nlme/nlme.pdf
#
#################################################


# this loads the required libraries
library(oro.nifti)
library(robumeta)
library(nlme)
library(rowr)
library(lme4)
library(MuMIn)


# this loads a text file containing scan's IDs and demographic and clinical covariates (age, IQ...)
# this must contain all and only kids with a rsfMRI scan or the rest of the code will not work.
subjectdata_f <- 'phenotypic_data_for_covariates_FIQ_meancentered.csv'
subjectdata <- read.csv(subjectdata_f)


# this recodes the subjectdata to match filenames.
# this will be used to create the list of subjects to be loaded.
subjectdata$diagnosis_renamed[subjectdata$diagnosis=="1"] <- "ASD"
subjectdata$diagnosis_renamed[subjectdata$diagnosis=="2"] <- "CTR"

subjectdata$site_renamed[subjectdata$site=="KKI"] <- "KKI"
subjectdata$site_renamed[subjectdata$site=="NYU"] <- "NYU"
subjectdata$site_renamed[subjectdata$site=="OHSU"] <- "Oregon"
subjectdata$site_renamed[subjectdata$site=="STANFORD"] <- "Stanford"
subjectdata$site_renamed[subjectdata$site=="UCLA_1"] <- "UCLA_1"
subjectdata$site_renamed[subjectdata$site=="UCLA_2"] <- "UCLA_2"
subjectdata$site_renamed[subjectdata$site=="UM_1"] <- "UM_1"
subjectdata$site_renamed[subjectdata$site=="YALE"] <- "Yale_scans"


# this loads the binary brainmask, edit the the path
mask_f <- '/media/DATA1/IIT_17Sep_Tsc2/01_rsfMRI_human_ABIDE1_Lombardo/Mask_ABIDE_85Percent_GM.nii.gz'
mask <- readNIfTI(mask_f) > 0 


# this creates a function that generates path/maps.nii.gz
# based on information contained in subjectdata
create.map.path <- function(subject) {
 
  measuremap_f <- paste("/media/DATA1/IIT_17Sep_Tsc2/01_rsfMRI_human_ABIDE1_Lombardo/05_younger_than_13yo/03_seed_based_analysis/03_subject_maps/", 
			subject$site_renamed,
			'_00',
			subject$ID, 
               		"_PP_",
			subject$diagnosis_renamed,
			"_resampled_MNI152_3mm_insular_seed_bilateral_from_tmap_covar_site_mixed_effect_no_censoring_z.nii.gz", sep="")

  return(measuremap_f)
}
create.map.path(subjectdata)


# this loads all the path/maps.nii.gz for each line of subjectdata 
measuremaps <- by(subjectdata, 1:nrow(subjectdata), create.map.path)

measure <- t(sapply(measuremaps, function(x) {
  message(x)
  readNIfTI(x)[mask]
}))



# -------------------------- filtering confounding variables ------------------------------- 
# ---- site as covariate of random intercept effect and IQ, age and sex fixed effect -------


# this merges subjectdata and measure in a single data frame.
# this is required for lmer to work.
measure_df <- data.frame(measure)
total = cbind.fill(subjectdata,measure_df)


# this selects only the voxel values part of total (i.e. image values)
vars = names(total)[c(12:49439)]


# this is the actual computation. To prevent RAM swapping, 
# I save only the residuals for each subject. 
tvals_mixed = lapply(setNames(vars, vars), function(var) {

  message(var)

  form = paste(var, " ~ FIQ_group_mean_centered + age + sex + (1 | site)")

  lmer.fit <- summary(lmer(form, data=total))

  resid(lmer.fit)

})


# this creates a function that generates names of the filtered maps
# based on information contained in subjectdata
create.map.name.filtered <- function(subject) {
 
  measuremap_f_filtered <- paste(subject$site_renamed,
				'_00',
				subject$ID, 
               			"_PP_",
				subject$diagnosis_renamed,
				"_resampled_MNI152_3mm_insular_seed_bilateral_from_tmap_covar_site_mixed_effect_no_censoring_z_filtered", sep="")

  return(measuremap_f_filtered)

}
map.name.filtered <- create.map.name.filtered(subjectdata)


# this converts filtered values into data frame and 
# merges names of the filtered maps and filtered values in a single data frame.
tvals_mixed_df = as.data.frame(tvals_mixed)
subjectdata_tvals_mixed_df = cbind.fill(map.name.filtered,tvals_mixed_df)


# this writes filtered nifti files
for(i in 1:nrow(subjectdata_tvals_mixed_df)) {

    # this defines a row
    row <- subjectdata_tvals_mixed_df[i,]

    # this gives to tmap_mixed the properties of mask.nii.gz
    tmap_mixed <- mask

    # this writes filtered values into tmap_mixed
    tmap_mixed@.Data[mask] <- unlist(subjectdata_tvals_mixed_df[i,2:49429])

    # this writes the filename
    filename=paste(subjectdata_tvals_mixed_df[i,1], sep="")

    # this writes the nifti file
    writeNIfTI(tmap_mixed, filename)

}
