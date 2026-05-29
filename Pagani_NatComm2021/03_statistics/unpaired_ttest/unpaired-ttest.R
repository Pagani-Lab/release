# This code simply carries out unpaired voxelwise t-test. 
#
# The output is identical to that obtained with AFNI's 3dttest++. 
#
# Make sure that your binary brainmask is set to "float".
#
# In this example site is the group-defining variable.
# ------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, IIT, Rovereto 
# Autism Center, CMI, New York
# April 2020
# ------------------------------------------

# this loads the required libraries
library(oro.nifti)


# this loads a text file containing subject IDs, site ID, and demographic 
# and clinical covariates (age, IQ...). this must contain all and only subjects 
# with a rsfMRI scan or the rest of the code will not work.
# make sure that the variable that identifies the group membership is in this file. 
subjectdata <- read.csv('phenotypic_data_for_covariates.csv')


# this recodes the subjectdata to match filenames.
# this will be used to create the list of subjects to be loaded.
subjectdata$site_renamed[subjectdata$site=="1"] <- "IIT"
subjectdata$site_renamed[subjectdata$site=="2"] <- "ETH"


# this loads the binary brainmask, edit the the path
mask_f <- 'chd8_functional_template_mask_wo_cerebellum_float.nii.gz'
mask <- readNIfTI(mask_f) > 0


# this creates a function that generates path/maps.nii.gz
# based on information contained in subjectdata
create.map.path <- function(subject) {
 
  measuremap_f <- paste("/path/", 
			subject$etiology, sep="")

  return(measuremap_f)
}
create.map.path(subjectdata)


# this loads all the path/maps.nii.gz for each line of subjectdata 
measuremaps <- by(subjectdata, 1:nrow(subjectdata), create.map.path)

measure <- t(sapply(measuremaps, function(x) {
  message(x)
  readNIfTI(x)[mask]
}))



# ------------------------ simple t-test -----------------------
# -------- site as covariate of random intercept effect --------

# this calculates the t-tests between diagnosis 
# for each voxels and outputs a summary
tests <- apply(measure, 2, function(x) {
         summary(lm(x ~ subjectdata$site))
         })

# this takes the t-value (third position  
# of the summary)  
tvals <- lapply(tests, function (x) {
         x$coefficients['subjectdata$site', 3]
         })

         # this writes the nifti file filled with t-values
tmap <- mask
tmap@.Data[mask] <- unlist(tvals)

writeNIfTI(tmap, file.path('unpaired_test'))

