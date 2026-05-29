# This code creates the inputs for combat i.e. the matrix from which you want 
# to remove the batch effect and the list of the covariates
#
# The inputs of this code are 
# - nifti files (global connectivity maps) that will be converted to voxels*subjects.csv
# - the phenotypic file to read selection criteria and generate the covariate.csv
#
# This code also takes care that the subjects in both csv are sorted alphabetically 
# so that voxels values are matched with phenotypic covariates.
#
# This code also downsample niftis. this may be useful to improve computational tractability
# during the implementation, however you are recommended to use native resolution for the
# real analysis (for example 2mm isotropic)
#
# ----------------------------------------
# Code written by Marco Pagani,
# Autism Center, CMI
# Functional Neuroimaging Laboratory, IIT
# May 2021
# ----------------------------------------



# edit this, path of nifti files to be copied based on selection criteria
nifti_path=/data3/autism_center/projects/marco/clustering_autism/04_global_connectivity/all/

# edit this, output path of copied nifti files based on inclusion criteria
nifti_path_included=$PWD/01_global_connectivity_maps/

# edit this, output path of resampled nifti files
nifti_path_included_resampled=$PWD/02_global_connectivity_maps_resampled/

# edit this, voxelsize for resampling. in case you don't want to resample use your native voxel size.
voxel_size=2

# edit this, brainmask
mask=$PWD/Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.nii.gz

# edit this, this file contains subject's ID and other clinical features to be used as selection criteria, use csv file
pheno_data=/data3/autism_center/projects/marco/clustering_autism/03_phenotypic_info/phenotypic_info_ABIDE1-2merged_21_wo_medianFD.csv

# inclusion criteria:

# edit this, select discovery dataset
discovery_replication_filter=1



# this creates output folders
mkdir $nifti_path_included
mkdir $nifti_path_included_resampled


	
# this copies only nifti files with inclusion criteria
while read line; do

        site_id=$(cut -f4 -d, <<< $line)
        sub_id=$(cut -f8 -d, <<< $line)
	nifti_id=$(cut -f7 -d, <<< $line)
	diagnosis=$(cut -f9 -d, <<< $line)
	age_at_scan=$(cut -f10 -d, <<< $line)
	sex=$(cut -f11 -d, <<< $line)
	nifti=$(cut -f12 -d, <<< $line)
	discovery_replication=$(cut -f14 -d, <<< $line)
	

	# inclusion criteria
	if (( $(echo "$discovery_replication == $discovery_replication_filter" | bc -l) )) ; then

		cp $nifti_path/${sub_id}*.nii.gz $nifti_path_included/
		
		feature_name=${sub_id}_globalconn_voxelwise 

		# this simply echoes copied files to terminal
		echo $feature_name $site_id $age_at_scan $discovery_replication
	
		# this creates the file with the covariates. The first input of combat	
		echo $feature_name $site_id $sex $diagnosis $age_at_scan >> abide_discovery_dataset_covariates_for_combat_unsorted.txt
	
		# this creates a list with the connectivity maps used, intermediate output	
		echo $feature_name >> connectivity_map_names_unsorted.txt
			
	fi

done < $pheno_data


# this converts the file with the covariates from txt to csv    
cat abide_discovery_dataset_covariates_for_combat_unsorted.txt | tr -s '[:blank:]' ',' > abide_discovery_dataset_covariates_for_combat_unsorted.csv

# this adds feature name to the first row of the file with the covariates	
sed -i "1i connectivity_map,site_id,sex,diagnosis,age_at_scan" abide_discovery_dataset_covariates_for_combat_unsorted.csv

# this sorts for the first column that is the name of the nifti files. comes in handy to match the subjects of the voxel*subject matrix
sort -k 1 abide_discovery_dataset_covariates_for_combat_unsorted.csv > abide_discovery_dataset_covariates_for_combat.csv

# this sortes the list of connectivity maps used
sort -k 1 connectivity_map_names_unsorted.txt > connectivity_map_names.txt








# this resamples the brainmask
3dresample \
	-dxyz $voxel_size $voxel_size $voxel_size \
	-prefix ${mask%.nii.gz}_resampled.nii.gz \
	-input $mask

# this resamples and converts global connectivity maps from nifti to txt
for feature in $nifti_path_included/*.nii.gz; do

        feature_name=$(basename $feature .nii.gz)

	echo $feature_name

	3dresample \
		-master ${mask%.nii.gz}_resampled.nii.gz \
		-rmode Linear \
		-prefix $nifti_path_included_resampled/${feature_name}_resampled.nii.gz \
		-input $feature

	3dmaskdump \
		-mask ${mask%.nii.gz}_resampled.nii.gz \
		-noijk \
		-o $nifti_path_included_resampled/${feature_name}_resampled.txt \
		$nifti_path_included_resampled/${feature_name}_resampled.nii.gz
		
	# this adds feature name in the first row, to check correspondence withthe file of the covariate	
	sed -i "1i $feature_name" $nifti_path_included_resampled/${feature_name}_resampled.txt

done


# this creates the voxels by subjects matrix. This is the second input of combat
# paste -d',' ${nifti_path_included_resampled}/*.txt >> voxels_subjects_matrix.csv

# use this in case you have more than 1000 subjects
# ls -1 ${nifti_path_included_resampled}/*.txt | split -l 1000 -d - lists
# for list in lists*; do paste $(cat $list) > merge${list##lists}; done
# paste merge* > voxels_subjects_matrix.csv

ls -1 ${nifti_path_included_resampled}/*.txt | split -l 1000 -d - lists
for list in lists*; do paste -d',' $(cat $list) > merge${list##lists}; done
paste -d',' merge* > voxels_subjects_matrix.csv



# this cleans the output.
rm $nifti_path_included_resampled/*_resampled.txt
rm ${mask%.nii.gz}_resampled.nii.gz 
rm abide_discovery_dataset_covariates_for_combat_unsorted.csv
rm abide_discovery_dataset_covariates_for_combat_unsorted.txt
rm connectivity_map_names_unsorted.txt
#rm lists0*
#rm merge0*
