# This code simply convert the csv file (output of combat) to 
# single subject nifti files
#
# ----------------------------------------
# Code written by Marco Pagani,
# Autism Center, CMI
# Functional Neuroimaging Laboratory, IIT
# May 2021
# ----------------------------------------

# edit this, output path where nifti files will be saved.
output_path=$PWD/04_combat_to_nifti/
mkdir $output_path

# edit this, brainmask
mask=$PWD/Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.nii.gz

# edit this, voxelsize for resampling
voxel_size=2

# edit this, txt file previously generated with (sorted) names of nifti files.
connectivity_maps_names=$PWD/connectivity_map_names.txt

# voxels by subjects matrix with batch effect removed i.e. the combat output
combat_output_csv=$PWD/03_combat/voxels_subjects_matrix_combat_without_preserved_covariates.csv


# this resamples the brainmask
3dresample \
	-dxyz $voxel_size $voxel_size $voxel_size \
	-prefix ${mask%.nii.gz}_resampled.nii.gz \
	-input $mask


# this creates the txt file with all the coordinates
3dmaskdump \
	-mask ${mask%.nii.gz}_resampled.nii.gz \
	-o rm.template_coordinates_resampled.txt \
	${mask%.nii.gz}_resampled.nii.gz


# this removes ones from the txt file with all the coordinates.
cut --complement -d' ' -f4 rm.template_coordinates_resampled.txt > template_coordinates_resampled.txt


# number of connectivity maps
sample_size=$(wc -l connectivity_map_names.txt | awk '{print $1}')


# this creates the niftis by matching the file with the coordinates and the connectivity values.
for i in $(seq 1 $sample_size); do

	# this extracts connectivity values for each voxel
	cut -d',' -f $i $combat_output_csv > ${output_path}/${i}.txt

	# this extracts connectivity maps names
	connectivity_name=$(sed "${i}q;d" $connectivity_maps_names)

	# this merges the templates and the connectivity values in a single txt
	paste -d" " template_coordinates_resampled.txt ${output_path}/${i}.txt > ${output_path}/${connectivity_name}.txt
	
	3dUndump \
		-prefix ${output_path}/${connectivity_name}.nii.gz \
		-datum float \
		-master ${mask%.nii.gz}_resampled.nii.gz \
		-ijk ${output_path}/${connectivity_name}.txt

	rm ${output_path}/${i}.txt

done

# this cleans the output
rm rm.template_coordinates_resampled.txt
rm ${mask%.nii.gz}_resampled.nii.gz
rm ${output_path}/*.txt
