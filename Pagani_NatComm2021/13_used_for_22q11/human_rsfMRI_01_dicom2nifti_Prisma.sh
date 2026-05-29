
# This code converts dicom2nifti, both resting state and anatomicals.
# Make sure you have mricron installed on your workstation and
# edit the path of dicom2nifti in this script before running the code.
#
# This code assumes that you folder structure of dicoms is: 
# - root/02_dicom/subID/MPRAGE/files.dcm
# - root/02_dicom/subID/REST/files.dcm
#
# ----------------------------------------
# Code written by Marco Pagani,
# Functional Neuroimaging Laboratory, IIT
# March 2021
# ----------------------------------------

numjobs=7 # edit this,

path_dicom=/media/DATA1/22q11_human/02_dicom/Prisma/ # edit this, path where dicom files are located
extracted_path=03_extracted_Prisma  # edit this, path where files.nii.gz will be extracted

mkdir $extracted_path

function dicom2nifti {
  	
        ts=$1
        
        subject=$(basename $ts ) 

	echo $ts
	echo $subject

	extracted_path=03_extracted_Prisma # edit this, path where files.nii.gz will be extracted

	mkdir $extracted_path/${subject}
		
	/home/imaging/tools/mricron/dcm2nii -4 ${ts}/*MPRAGE*/*
	cp ${ts}/*MPRAGE*/co*.nii.gz $extracted_path/${subject}/mprage.nii.gz

	/home/imaging/tools/mricron/dcm2nii -4 ${ts}/*REST*/*
	cp ${ts}/*REST*/*REST*.nii.gz $extracted_path/${subject}/rest.nii.gz

	rm ${ts}/*MPRAGE*/*.nii.gz
	rm ${ts}/*REST*/*REST*.nii.gz

}

export -f dicom2nifti

# Main code starts here
echo $path_dicom/* | tr " " "\n" > subject_list.txt
parallel \
    -j $numjobs \
    dicom2nifti {} \
    < subject_list.txt
