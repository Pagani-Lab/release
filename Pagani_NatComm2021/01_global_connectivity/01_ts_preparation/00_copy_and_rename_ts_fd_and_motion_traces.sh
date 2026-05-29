# this script copies and renames ABIDE ts and motion traces
# as preprocessed by Lombardo to a new folder. This is the
# initial step for further processing

datapath=$PWD/03_sites_with_young_patients_and_controls/ # edit this
newdir=04_renamed # edit this


mkdir $newdir

for subdir in $datapath/*_PP/*; do 

	site=$(echo $subdir | rev | cut -d / -f2 | rev)
	name=$(echo $subdir | rev | cut -d / -f1 | rev)
	
	echo $site $name


	cp $subdir/rest_pp.nii.gz $PWD/$newdir/${site%_PP}_${name}.nii.gz
	cp $subdir/rest_motion.1D $PWD/$newdir/${site%_PP}_${name}_motion_traces.txt 
	cp $subdir/rest_motion_fd.txt $PWD/$newdir/${site%_PP}_${name}_fd.txt
	
done
