
% Run this matlab code in the folder containing subject_roi_ts.txt
% i.e. the file with mean timeseries per regions created by 01_subject_roi_ts.sh
%
% The output is a roi-to-roi correlation matrix for each mouse

myFiles = dir(fullfile(pwd,'*.txt')); %gets all txt files in struct

for k = 1:length(myFiles)
  
  % creating basename and fullname
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(pwd, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  
  % importing data
  data = importdata(fullFileName);   
  
  % calulating correlation matrix
  rho = corr(data, 'rows','pairwise');

  % zeroing the nans
  rho(isnan(rho))=0;
  
  % check if mean exists
  M(k) = mean(rho,'all');
  
  % subset 400*400
  rho=rho(1:400,1:400);
  
  % check for matrix size
  S(k,:) = size(rho);
  
  %thresholding for sparcity 95%, 
  %rho_vector = rho(:);
  %sparcity = prctile(rho_vector,95);
  %rho(rho<sparcity) = 0;
  %rho(rho>=sparcity) = 1;

  % save matrices in .txt files
  filename = ['correlation_matrix_', baseFileName];
  dlmwrite(filename,rho,' ')
  
end

