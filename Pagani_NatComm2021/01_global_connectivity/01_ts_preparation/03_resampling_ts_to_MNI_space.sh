# this script resamples all ts to MNI 3 mm space  

path_ts=$PWD/05_younger_than_13/

MNI=/media/DATA1/IIT_17Sep_Tsc2/01_rsfMRI_human_ABIDE1_Lombardo/MNI152_T1_3mm_brain.nii.gz

cd $path_ts

for ts in $path_ts/*.nii.gz; do 

	3dresample \
		-master $MNI \
		-prefix ${ts%.nii.gz}_resampled_MNI152_3mm.nii.gz \
		-input $ts

done

cd ..
