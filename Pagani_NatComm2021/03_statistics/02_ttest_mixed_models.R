# Web resources
# https://www.alexejgossmann.com/MRI_viz/
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


# this loads a text file containing scan's IDs and 
# demographic and clinical covariates (age, IQ...)
# this must contain all and only kids with
# a rsfMRI scan or the rest of the code will not work.
subjectdata_f <- 'phenotypic_data_for_covariates.csv'
subjectdata <- read.csv(subjectdata_f)


# this recodes the subjectdata to match filenames.
# this will be used to create the list of subjects
# to be loaded.
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


# this creates the output directory
if (!file.exists('tests')) {
  dir.create('tests')
}


# this creates a function that generates path/maps.nii.gz
# based on information contained in subjectdata
create.map.path <- function(subject) {
 
  measuremap_f <- paste("/media/DATA1/IIT_17Sep_Tsc2/01_rsfMRI_human_ABIDE1_Lombardo/06_gbcmaps/", 
			subject$site_renamed,
			'_00',
			subject$ID, 
               		"_PP_",
			subject$diagnosis_renamed,
			"_resampled_MNI152_3mm_globalconn.nii.gz", sep="")

  return(measuremap_f)
}
create.map.path(subjectdata)


# this loads all the path/maps.nii.gz for each line 
# of subject data by using readNifTI and create.map.path
measuremaps <- by(subjectdata, 1:nrow(subjectdata), create.map.path)

measure <- t(sapply(measuremaps, function(x) {
  readNIfTI(x)[mask]
}))




# ---------- Simple t-test ----------
outdir = 'tests/01_r_nocovar'
if (!file.exists(outdir)) {
    print('Simple t-test')
    dir.create(outdir)


    # this calculates the t-tests between diagnosis 
    # for each voxels and outputs a summary
    tests <- apply(measure, 2, function(x) {
      summary(lm(x ~ subjectdata$diagnosis))
    })


    # this takes the t-value (third position  
    # of the summary)  
    tvals <- lapply(tests, function (x) {
      x$coefficients['subjectdata$diagnosis', 3]
    })


    # this takes the p-value (fourth position  
    # of the summary) 
    pvals <- lapply(tests, function(x) {
      -log10(x$coefficients['subjectdata$diagnosis', 4])
    })


    # this writes the nifti file, one with t-values
    # and one with p-values 
    tmap <- mask
    tmap@.Data[mask] <- unlist(tvals)

    pmap <- mask
    pmap@.Data[mask] <- unlist(pvals)

    writeNIfTI(tmap, file.path(outdir, 'tmap_nocovar'))
    writeNIfTI(pmap, file.path(outdir, 'pmap_nocovar'))
}




# ---------- T-test with site as covariate fixed effect ----------
outdir = 'tests/02_r_covar_site_fixed_effect'
if (!file.exists(outdir)) {
    print('T-test with site as covariates fixed effect')
    dir.create(outdir)

    tests_covar <- apply(measure, 2, function(x) {
      summary(lm(x ~ subjectdata$diagnosis + subjectdata$site))
    })

    tvals_covar <- lapply(tests_covar, function (x) {
      x$coefficients['subjectdata$diagnosis', 3]
    })

    pvals_covar <- lapply(tests_covar, function(x) {
      -log10(x$coefficients['subjectdata$diagnosis', 4])
    })

    tmap_covar <- mask
    tmap_covar@.Data[mask] <- unlist(tvals_covar)

    pmap_covar <- mask
    pmap_covar@.Data[mask] <- unlist(pvals_covar)

    writeNIfTI(tmap_covar, file.path(outdir, 'tmap_covar_site_fixed_effect'))
    writeNIfTI(pmap_covar, file.path(outdir, 'pmap_covar_site_fixed_effect'))
}




# ---------- T-test with site and IQ as covariate fixed effect ----------
outdir = 'tests/03_r_covar_site_IQ_fixed_effect'
if (!file.exists(outdir)) {
    print('T-test with site and IQ as covariates fixed effect')
    dir.create(outdir)

    tests_covar <- apply(measure, 2, function(x) {
      summary(lm(x ~ subjectdata$diagnosis + subjectdata$site + subjectdata$FIQ))
    })

    tvals_covar <- lapply(tests_covar, function (x) {
      x$coefficients['subjectdata$diagnosis', 3]
    })

    pvals_covar <- lapply(tests_covar, function(x) {
      -log10(x$coefficients['subjectdata$diagnosis', 4])
    })

    tmap_covar <- mask
    tmap_covar@.Data[mask] <- unlist(tvals_covar)

    pmap_covar <- mask
    pmap_covar@.Data[mask] <- unlist(pvals_covar)

    writeNIfTI(tmap_covar, file.path(outdir, 'tmap_covar_site_IQ_fixed_effect'))
    writeNIfTI(pmap_covar, file.path(outdir, 'pmap_covar_site_IQ_fixed_effect'))
}




# ---------- T-test with site, IQ, age, sex as covariate fixed effect ----------
outdir = 'tests/04_r_covar_site_IQ_age_sex_fixed_effect'
if (!file.exists(outdir)) {
    print('T-test with site, IQ, age, sex as covariate fixed effect')
    dir.create(outdir)

    tests_covar <- apply(measure, 2, function(x) {
      summary(lm(x ~ subjectdata$diagnosis + subjectdata$site + subjectdata$FIQ + subjectdata$age + subjectdata$sex))
    })

    tvals_covar <- lapply(tests_covar, function (x) {
      x$coefficients['subjectdata$diagnosis', 3]
    })

    pvals_covar <- lapply(tests_covar, function(x) {
      -log10(x$coefficients['subjectdata$diagnosis', 4])
    })

    tmap_covar <- mask
    tmap_covar@.Data[mask] <- unlist(tvals_covar)

    pmap_covar <- mask
    pmap_covar@.Data[mask] <- unlist(pvals_covar)

    writeNIfTI(tmap_covar, file.path(outdir, 'tmap_covar_site_IQ_age_sex_fixed_effect'))
    writeNIfTI(pmap_covar, file.path(outdir, 'pmap_covar_site_IQ_age_sex_fixed_effect'))
}




# ---------- T-test with site as covariate random intercept effect ----------
outdir = 'tests/05_r_covar_site_random_intercept_effect'
if (!file.exists(outdir)) {
    print('T-test with site as covariates mixed effect')
    dir.create(outdir)

# this merges subjectdata and measure in a single data frame.
# this is required for lmer to work.
measure_df <- data.frame(measure)
total = cbind.fill(subjectdata,measure_df)

# this selects only the measure part of total (i.e. image values)
vars = names(total)[c(12:49439)]

# this is the actual computation. To prevent RAM swapping, 
# this function do not save the whole summary, only the t-stat. 
tvals_mixed = lapply(setNames(vars, vars), function(var) {

  message(var)

  form = paste(var, " ~ diagnosis + (1 | site)")

  lmer.fit <- summary(lmer(form, data=total))

  return(lmer.fit$coefficients['diagnosis',3])

})


# this creates the nifti file.
tmap_mixed <- mask
tmap_mixed@.Data[mask] <- unlist(tvals_mixed)

writeNIfTI(tmap_mixed, file.path(outdir, 'tmap_covar_site_random_intercept_effect'))

}




# ---------- T-test with site as covariate random intercept effect and IQ fixed effect ----------
outdir = 'tests/06_r_covar_site_random_intercept_effect_IQ_fixed_effect'
if (!file.exists(outdir)) {
    print('T-test with site as covariate random intercept effect and IQ fixed effect')
    dir.create(outdir)

# this merges subjectdata and measure in a single data frame.
# this is required for lmer to work.
measure_df <- data.frame(measure)
total = cbind.fill(subjectdata,measure_df)

# this selects only the measure part of total (i.e. image values)
vars = names(total)[c(12:49439)]

# this is the actual computation. To prevent RAM swapping, 
# this function do not save the whole summary, only the t-stat. 
tvals_mixed = lapply(setNames(vars, vars), function(var) {

  message(var)

  form = paste(var, " ~ diagnosis + FIQ + (1 | site)")

  lmer.fit <- summary(lmer(form, data=total))

  return(lmer.fit$coefficients['diagnosis',3])

})

# this creates the nifti file.
tmap_mixed <- mask
tmap_mixed@.Data[mask] <- unlist(tvals_mixed)

writeNIfTI(tmap_mixed, file.path(outdir, 'covar_site_random_intercept_effect_IQ_fixed_effect'))

}




# ---------- T-test with site as covariate random intercept effect and IQ age sex fixed effect ----------
outdir = 'tests/07_r_covar_site_random_intercept_effect_IQ_age_sex_fixed_effect'
if (!file.exists(outdir)) {
    print('T-test with site as covariate random intercept effect and IQ age and sex fixed effect')
    dir.create(outdir)

# this merges subjectdata and measure in a single data frame.
# this is required for lmer to work.
measure_df <- data.frame(measure)
total = cbind.fill(subjectdata,measure_df)

# this selects only the measure part of total (i.e. image values)
vars = names(total)[c(12:49439)]

# this is the actual computation. To prevent RAM swapping, 
# this function do not save the whole summary, only the t-stat. 
tvals_mixed = lapply(setNames(vars, vars), function(var) {

  message(var)

  form = paste(var, " ~ diagnosis + FIQ + age + sex + (1 | site)")

  lmer.fit <- summary(lmer(form, data=total))

  return(lmer.fit$coefficients['diagnosis',3])

})

# this creates the nifti file.
tmap_mixed <- mask
tmap_mixed@.Data[mask] <- unlist(tvals_mixed)

writeNIfTI(tmap_mixed, file.path(outdir, 'covar_site_random_intercept_effect_IQ_age_sex_fixed_effect'))

}












###########################################################################
###########################################################################
# this keeps only the data 
a<-file.exists(create.map.path(subjectdata))
b<-create.map.path(subjectdata)[!(a=="FALSE")]
c<-subjectdata[!(a=="FALSE"),]


# this is the code to get t-values of diagnosis in random mixed models

lme(age ~ diagnosis, random = ~ 1|site, data=subjectdata)
summary(fit_lme)$tTable['diagnosis',4]



