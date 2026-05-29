# this code simply transposes the output of combat
#
# ----------------------------------------
# Code written by Marco Pagani,
# Autism Center, CMI
# Functional Neuroimaging Laboratory, IIT
# May 2021
# ----------------------------------------


library(data.table)

# set number of cores
setDTthreads(10)

# load the matrix
subjects_voxels_matrix <-fread("/data3/autism_center/projects/marco/clustering_autism/07_discovery/03_combat/subjects_voxels_matrix_combat_without_preserved_covariates.csv", sep = ",", header = F)

# dimensions of the matrix
dim(subjects_voxels_matrix)

# transpose the matrix so that subjects are the raws 
voxels_subjects_matrix <- t(subjects_voxels_matrix)

# dimensions of the matrix
dim(voxels_subjects_matrix)

# save trasposed matrix
fwrite(voxels_subjects_matrix, "/data3/autism_center/projects/marco/clustering_autism/07_discovery/03_combat/voxels_subjects_matrix_combat_without_preserved_covariates.csv", col.names = FALSE)
