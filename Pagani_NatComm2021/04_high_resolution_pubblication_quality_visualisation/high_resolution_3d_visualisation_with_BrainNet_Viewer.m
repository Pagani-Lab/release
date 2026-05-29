%
% This code enables to generate high quality 3D rendering of the human brain
% and add overlays of your beautiful statistical maps.
%
% Before using this code make sure you have downloaded the matlab toolbox 
% BrainNet Viewer version 2017 (https://www.nitrc.org/projects/bnv/).
%
% There are some brain surfaces already included in the toolbox, however my
% favourite is the one published in Glasser and Van Essen, Nature 2016.
% (https://www.nature.com/articles/nature18933). This is the brain surface
% of the Human Connectome Project that can be downloaded from BALSA Lab 
% (https://balsa.wustl.edu/WN56). The only issue here was that the BrainNet 
% has to be fed with a single surface.nv file containing both right
% and left hemisphere whereas the HCP surface comes with separated hemispheres
% in gifti format:
%
% - Glasser_et_al_2016_HCP_MMP1.0_qN_RVVG/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/
%   MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210.L.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii
% - Glasser_et_al_2016_HCP_MMP1.0_qN_RVVG/HCP_PhaseTwo/Q1-Q6_RelatedParcellation210/
%   MNINonLinear/fsaverage_LR32k/Q1-Q6_RelatedParcellation210.R.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR.surf.gii
%
% To merge right and left hemisphere I used Tools/Merge_Mesh available for 
% the GUI of BrainNet Viewer. The trick I used here was to merge right.gii 
% and right.gii to create right.nv, and I did the same for left hemisphere. 
% Then I merged right.nv and left.nv in a single file named:
% Q1-Q6_RelatedParcellation210.LR.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR_left_right.surf.nv
% that is the brain surface you may want to use for BrainNet Viewer.
%
% Before using this code to automatically generate as many maps as you like, 
% you may want to manually load the brain surface and one exemplificative
% statistics.nii.gz to the GUI and set your preferred colors, views, 
% thresholds etc.. etc.. and save these preferences in a configuration_file.mat. 
% This mat file will be given as input to this code and all these preferences 
% will be automatically applied to all the images. If you don't know what 
% I am talking about, please read the manual of the BrainNet toolbox, that 
% is well written and greatly informative!
%
% Also, make sure that your overlays (i.e. statistics) are in nifti format
% and registered to the MNI space. Specifically, this code is meant for cases
% where you have brainmaps of statistics of one-sample and two sample t-test,
% with minor edits you should be able to use this code for any statistical map.
%
% After running this code and realising how much time you have saved and the 
% beautiful quality of the output, remember that coding make me thirsty 
% than feel free to offer me as many pints as you want :)
%
% ----------------------------------------
% Code written by Marco Pagani,
% Functional Neuroimaging Laboratory, IIT
% November 2020
% ----------------------------------------


clc, clear all


%% 01. setting the paths

% edit this, this is the path of the BrainNet Viewer Toolboax and all its subfolders.
addpath(genpath('/path/to/BrainNetViewer_20170403'));

% edit this, this is the two_hemispheres_brain_surface.nv with path 
brain_surface = '/path/to/Q1-Q6_RelatedParcellation210.LR.inflated_MSMAll_2_d41_WRN_DeDrift.32k_fs_LR_left_right.surf.nv';

% edit this, output file.png
output_path = '/path/to/pngs/';
mkdir(output_path);

% edit this, this is the path of the overlays.nii.gz of one-sample
% and two-sample statistics (i.e. the results you want to visualize)
overlays_path = '/path/to/brainmaps/';

% edit this, this creates a list of the overlays of one-sample statistics
overlays_onesample = dir(fullfile(overlays_path, '*your_stat*.nii.gz'));

% edit this, this creates a list of the overlays of two-sample statistics
overlays_twosample = dir(fullfile(overlays_path, '*your_stat*.nii.gz'));

% edit this, configuration file of one-sample statistics with path
configuration_file_onesample = '/path/to/configuration_file_one_sample.mat';

% edit this, configuration file of two-sample statistics with path
configuration_file_twosample = '/path/to/configuration_file_two_sample.mat';



%% 02. creating .pngs for one-sample statistics

for overlay = 1:length(overlays_onesample)
    
  % creating filename for each overlay
  overlay_filename = overlays_onesample(overlay).name;
  disp(overlay_filename)
  
  % selecting each overlay with fullpath
  overlay_filename_with_path = fullfile(overlays_path, overlay_filename);
  disp(overlay_filename_with_path)
  
  % removing suffix .nii.gz from filename
  overlay_filename_without_extension = [overlay_filename(1:end-7)];
  disp(overlay_filename_without_extension)
  
  % creating filename for outputs.png for each overlay
  overlay_filename_output_with_path = [output_path overlay_filename_without_extension '.png'];
  disp(overlay_filename_output_with_path)
    
  % reading this overlay  
  fprintf(1, 'Now reading %s\n', overlay_filename_with_path);
    
  % main code
  BrainNet_MapCfg(brain_surface, overlay_filename_with_path, configuration_file_onesample, overlay_filename_output_with_path);
    
end



%% 03. creating .pngs for two-sample statistics

for overlay = 1:length(overlays_twosample)
    
  % creating filename for each overlay
  overlay_filename = overlays_twosample(overlay).name;
  disp(overlay_filename)
  
  % selecting each overlay with fullpath
  overlay_filename_with_path = fullfile(overlays_path, overlay_filename);
  disp(overlay_filename_with_path)
  
  % removing suffix .nii.gz from filename
  overlay_filename_without_extension = [overlay_filename(1:end-7)];
  disp(overlay_filename_without_extension)
  
  % creating filename for outputs.png for each overlay
  overlay_filename_output_with_path = [output_path overlay_filename_without_extension '.png'];
  disp(overlay_filename_output_with_path)
    
  % reading this overlay  
  fprintf(1, 'Now reading %s\n', overlay_filename_with_path);
    
  % main code
  BrainNet_MapCfg(brain_surface, overlay_filename_with_path, configuration_file_twosample, overlay_filename_output_with_path);
    
end
