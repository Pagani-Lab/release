
threshold=0.2
atlas_name=occurence_map_pos.nii.gz


for img in *.nii.gz; do

fslmaths $img -thr $threshold -bin ${img%.nii.gz}_thr_bin.nii.gz

done


# this creates an empty file
empty=$(ls *_thr_bin.nii.gz | sort -n | head -1)

ImageMath 3 \
	$atlas_name \
	m $empty \
	0

# this is for the remainging labels
for label in *_thr_bin.nii.gz ; do

	echo $label

	ImageMath 3 \
		$atlas_name \
		+ $atlas_name \
		$label
done

