path_ts=$PWD/01_seed_based_maps_filtered/

mkdir 02_NbClust

mask=Mask_ABIDE_85Percent_GM.nii.gz

3dresample \
	-dxyz 6 6 6 \
	-prefix ${mask%.nii.gz}_resampled.nii.gz \
	-input $mask

for ts in $path_ts/*.nii.gz; do

        echo $ts

	3dresample \
		-dxyz 6 6 6 \
		-prefix ${ts%}_resampled.nii.gz \
		-input $ts

	3dmaskdump \
		-mask ${mask%.nii.gz}_resampled.nii.gz \
		-noijk \
		-o ${ts%.nii.gz}.txt \
		${ts%}_resampled.nii.gz

rm ${ts%}_resampled.nii.gz

done

cd $path_ts

paste -d' ' *CTR*.txt >> all_CTR.txt
paste -d' ' *ASD*.txt >> all_ASD.txt

cd ..
