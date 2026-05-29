
threshold=0.5
atlas_name_pos=occurence_map_pos.nii.gz
atlas_name_neg=occurence_map_neg.nii.gz
atlas_name=occurence_map.nii.gz

# this creates binarised mask of positive values
for img in stat_*.nii.gz; do

fslmaths \
	$img \
	-thr $threshold \
	-bin rm.${img%.nii.gz}_thr_pos_bin.nii.gz

done

# this creates an empty file
empty=$(ls rm.*_thr_pos_bin.nii.gz | sort -n | head -1)

fslmaths \
	$empty \
	-mul 0 \
	$atlas_name_pos

# this sums the binarised mask of positive values
for label in rm.*_thr_pos_bin.nii.gz ; do

echo $label

ImageMath 3 \
	$atlas_name_pos \
	+ $atlas_name_pos \
	$label
done




# this creates binarised mask of negative values
for img in stat_*.nii.gz; do

	fslmaths \
		$img \
		-mul -1 \
		rm.${img%.nii.gz}_neg.nii.gz

	fslmaths \
		rm.${img%.nii.gz}_neg.nii.gz \
		-thr $threshold \
		-bin rm.${img%.nii.gz}_thr_neg_bin.nii.gz

	rm rm.${img%.nii.gz}_neg.nii.gz

done

# this creates an empty file
empty=$(ls rm.*_thr_neg_bin.nii.gz | sort -n | head -1)

fslmaths \
	$empty \
	-mul 0 \
	$atlas_name_neg


# this sums the binarised mask of negative values
for label in rm.*_thr_neg_bin.nii.gz ; do

echo $label

ImageMath 3 \
	$atlas_name_neg \
	+ $atlas_name_neg \
	$label
done






# this creates an empty file
empty=$(ls rm.*_thr_*_bin.nii.gz | sort -n | head -1)

fslmaths \
	$empty \
	-mul 0 \
	$atlas_name


# this sums the binarised mask of negative values
for label in rm.*_thr_*_bin.nii.gz ; do

echo $label

ImageMath 3 \
	$atlas_name \
	+ $atlas_name \
	$label
done


rm rm.*
