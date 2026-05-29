
donor_MRI=T1_donor12876.nii.gz

# before using this code, remember to remove all non-separator commas from CSV annotated file 

sed 1d SampleAnnot.csv | while read line_SampleAnnot; do

	# this stores id and xyz coordinates  
	well_id=`echo "$line_SampleAnnot" | awk -F',' '{print $3}'`
	x=`echo "$line_SampleAnnot" | awk -F',' '{print $8}'`
	y=`echo "$line_SampleAnnot" | awk -F',' '{print $9}'`
	z=`echo "$line_SampleAnnot" | awk -F',' '{print $10}'`	
	
	echo "$x $y $z 1" > ${x}_${y}_${z}.txt

	3dUndump \
		-prefix wellid_${well_id}_xyz_${x}_${y}_${z}.nii.gz \
		-master $donor_MRI \
		${x}_${y}_${z}.txt

	rm ${x}_${y}_${z}.txt

done


fslmerge \
	-t 4d_wellid.nii.gz \
	wellid_*_xyz_*.nii.gz


fslmaths \
	4d_wellid.nii.gz \
	-Tmean \
	-bin \
	T1_donor12876_location_of_sampling.nii.gz

rm wellid_*_xyz_*.nii.gz
rm 4d_wellid.nii.gz

