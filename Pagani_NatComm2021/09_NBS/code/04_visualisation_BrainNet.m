# Visualisation is based on FSL and the matlab toolbox "BrainNet" 

# 1)
# Calculate centers of gravity and create shank3.node.
# The two 1s controls size and color
# Calculate center of gravity from labels of hires morfological template.   

for roi in *; do 
	echo `fslstats "$roi" -c` 1 1 "$roi" >> file.node 
done

# 2)
# Use the mask of the high res morfological template
# Dato che BrainNet vuole superfici in mask.vn, use this to convert mask.nii (not .gz) to mask.vn
#
# For better visualisation, I change this line 
# vol = smooth3(surf_vol,'box',5);
# in BrainNet_GenSurface.m

BrainNet_GenSurface('mask.nii','mask.nv',0.5)


