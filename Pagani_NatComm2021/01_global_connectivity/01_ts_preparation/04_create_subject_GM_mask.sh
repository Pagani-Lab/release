# this script creates a GM mask for each subject

path_ts=$PWD/05_younger_than_13/

template_GM_mask=Mask_ABIDE_85Percent_GM.nii.gz

for ts in $path_ts/*_PP_*_3mm.nii.gz; do

# this calculates the temporal mean    
3dTstat \
	-mean \
        -prefix ${ts%.nii.gz}_mean.nii.gz \
        $ts

# this creates the subject mask
fslmaths \
	${ts%.nii.gz}_mean.nii.gz \
	-bin \
	${ts%.nii.gz}_mask.nii.gz

# this creates the GM subject mask
fslmaths \
	${ts%.nii.gz}_mask.nii.gz \
	-mul \
	$template_GM_mask \
	${ts%.nii.gz}_GM_mask.nii.gz

rm ${ts%.nii.gz}_mean.nii.gz
	
done
