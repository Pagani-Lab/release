# this script copies and renames ABIDE ts and motion traces
# as preprocessed by Lombardo to a new folder. This is the
# initial step for further processing

pp_path_trio=$PWD/04_pp_Trio/ # edit this
pp_path_prisma=$PWD/04_pp_Prisma/ # edit this

inputs_path=$PWD/05_carpet_plot/ # edit this
mkdir $inputs_path


# Trio

for subdir in $pp_path_trio/*; do

	name=$(echo $subdir | rev | cut -d / -f1 | rev)

	echo $name

	cp $subdir/Erest_pp.nii.gz $inputs_path/${name}_pp_BOLD.nii.gz
	cp $subdir/Erest_motion.1D $inputs_path/${name}_pp_motion_traces.txt
	cp $subdir/plots/Erest_wds_dvars.txt $inputs_path/${name}_pp_DVARS.txt
	cp $subdir/spp.Erest/eBvrmask.nii.gz $inputs_path/${name}_pp_brainmask.nii.gz

done


# Prisma

for subdir in $pp_path_prisma/*; do

	name=$(echo $subdir | rev | cut -d / -f1 | rev)

	echo $name

	cp $subdir/Erest_pp.nii.gz $inputs_path/${name}_pp_BOLD.nii.gz
	cp $subdir/Erest_motion.1D $inputs_path/${name}_pp_motion_traces.txt
	cp $subdir/plots/Erest_wds_dvars.txt $inputs_path/${name}_pp_DVARS.txt
	cp $subdir/spp.Erest/eBvrmask.nii.gz $inputs_path/${name}_pp_brainmask.nii.gz

done
