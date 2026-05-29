# this script resamples all ts to MNI 3 mm space  

MNI=/media/DATA1/22q11_human/MNI152_T1_3mm_brain.nii.gz

pp_path_trio=$PWD/04_pp_Trio/ # edit this
pp_path_prisma=$PWD/04_pp_Prisma/ # edit this

inputs_path=$PWD/06_resampled_to_MNI # edit this
mkdir $inputs_path


# Trio

for subdir in $pp_path_trio/* ; do

	name=$(echo $subdir | rev | cut -d / -f1 | rev)
	
	echo $name

	cp $subdir/Erest_pp.nii.gz $inputs_path/${name}_pp_BOLD.nii.gz

	3dresample \
		-master $MNI \
		-prefix $inputs_path/${name}_resampled_MNI152_3mm.nii.gz \
		-input $inputs_path/${name}_pp_BOLD.nii.gz

rm $inputs_path/${name}_pp_BOLD.nii.gz

done


# Prisma

for subdir in $pp_path_prisma/* ; do

	name=$(echo $subdir | rev | cut -d / -f1 | rev)

	echo $name

	cp $subdir/Erest_pp.nii.gz $inputs_path/${name}_pp_BOLD.nii.gz

	3dresample \
		-master $MNI \
		-prefix $inputs_path/${name}_resampled_MNI152_3mm.nii.gz \
		-input $inputs_path/${name}_pp_BOLD.nii.gz

rm $inputs_path/${name}_pp_BOLD.nii.gz

done
