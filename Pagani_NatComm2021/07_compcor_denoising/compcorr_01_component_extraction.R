#
# this code extract structured noise components from fMRI ts 
# by using CompCor denoising as implemented in ANTsR:
# https://www.rdocumentation.org/packages/ANTsR/versions/1.0/topics/compcor
#
# main reference for CompCor denoising is:
# https://www.sciencedirect.com/science/article/pii/S1053811907003837
#
# before running this code remember to install ANTsR following these instructions:
# https://www.rdocumentation.org/packages/ANTsR/versions/1.0
#
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# Autism Center, CMI
# February 2021
# ----------------------------------------

# loading required libraries
library(ANTsR)
library(stringr)


# edit this, path of nifti files to be regressed
ts_path = '/media/DATA1/IIT_17Sep_Tsc2/08_revisions_natcomm/10_ANTsR_compcorr/01_ts_resampled_MNI/'

# edit this, this is the noise mask that usually is a white matter mask (with path)
WM_mask = '/media/DATA1/IIT_17Sep_Tsc2/08_revisions_natcomm/10_ANTsR_compcorr/avg152T1_white_bin.nii.gz'



# this loads white matter mask to be regressed
WM_noisemask <- antsImageRead(WM_mask)

# this creates a list of the nifti files to be regressed 
nifti_list <- dir(path = ts_path, pattern = "\\.nii.gz$", full.names = TRUE, recursive = TRUE)



# comp corr denoising
measure <- t(sapply(nifti_list, function(x) {
  
  # echo ts
  message(x)

  # read ts
  ts <- antsImageRead(x)
  
  # actual compcorr computation
  compcorr_nuisance <- compcor(ts, 
			       WM_noisemask, 
			       ncompcor = 4, 
			       variance_extreme = 0.975, 
			       returnhighvarmat = F, 
			       returnv = F)

  # create output filename for components to be regressed
  # ts_basename <- gsub('.{7}$', '', x)
  ts_basename <- str_sub(x, end=-8)
  ts_txt <- paste(ts_basename, "_structured_noise.txt")
  ts_txt_nospaces <- gsub(" ", "", ts_txt, fixed = TRUE)
 
  # write components in a .txt file
  write.table(compcorr_nuisance, file=ts_txt_nospaces, row.names=FALSE, col.names=FALSE)
  
}))

