# This code calculates Combat to remove batch effects.
# Originally written by Nick Cullen https://github.com/Jfortin1/neuroCombat
#
# The inputs are: 
# - a voxels_subjects_matrix.csv (the header is the subject names). 
#   this is usually a connectivity matrix from which you aim to remove the batch effect
# - a covariate_list.csv (the header is the covariate names), that includes a column with the batch
#   covariate and other colums with the covarates you want to preserve (e.g.
#   age, sex...).
#
# The output is: 
# - voxels_subjects_matrix_combat_without_preserved_covariates.csv
#
# All the few parameters you would like to edit are at the end of the neuroCombat.py
# after "loading spreadsheets". This includes the inputs that are hardcoded in the neuroCombat.py.
#
# Important: 
# - subjects must be sorted in the same way in both inputs to properly
#   match connectivity values and covariates. this is already checked for you.
# - this code simply uses neuroCombat.py edited by Marco so that make sure you have it with you 
# - this code has been tested for python2
# - by editing neuroCombat.py you can easily remove the batch effects by preserving covariates of intereset
#
# Marco edits with respect to Jose version are the following
# https://github.com/Jfortin1/neuroCombat/compare/f50dd2dfba0c07d5a602f5cc0ea63c73e9969f75...64aa83e805ddb87c2ffc217b2ac5e819f3009b5c#
#
# ----------------------------------------
# Code written by Marco Pagani,
# Autism Center, CMI
# Functional Neuroimaging Laboratory, IIT
# May 2021
# ----------------------------------------


output_dir=03_combat

mkdir $output_dir

# this does the actual remove of batch effect
python3 neuroCombat.py


# this move the output in the output folder.
mv $PWD/abide_discovery_dataset_covariates_for_combat.csv $output_dir

mv $PWD/voxels_subjects_matrix.csv $output_dir

mv $PWD/subjects_voxels_matrix_combat_without_preserved_covariates.csv $output_dir

mv $PWD/voxels_subjects_matrix_combat_without_preserved_covariates.csv $output_dir

# mv $PWD/subjects_voxels_matrix_combat_with_preserved_covariates.csv $output_dir

# mv $PWD/voxels_subjects_matrix_combat_with_preserved_covariates.csv $output_dir


