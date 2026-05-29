% https://it.mathworks.com/matlabcentral/answers/2849-euclidean-distance-of-two-vectors
% 50806 removed


% gets all txt files in structure
myFiles = dir(fullfile(pwd,'*.txt')); 

for k = 1:length(myFiles)

  % echo numero di scan
  disp(k)
  
  % creating basename and fullname
  baseFileName = myFiles(k).name;
  fullFileName = fullfile(pwd, baseFileName);
  fprintf(1, 'Now reading %s\n', fullFileName);
  
  % importing data
  data = importdata(fullFileName).';   

  % vectorize global connectivity maps and save it in a single matrix
  rho_all_matrix(k,:) = data;

end




% remove nan values
rho_all_matrix(isnan(rho_all_matrix)) = 0;

% this calculates the euclidean distance between connectivity matrix of pairs of brains
eucl_dist = pdist(rho_all_matrix, 'euclidean');
eucl_dist_results = squareform(eucl_dist);

% this calculates the cosine distance between connectivity matrix of pairs of brains
cosine_dist = pdist(rho_all_matrix, 'cosine');
cosine_dist_results = squareform(cosine_dist);

% this calculates the correlation distance between connectivity matrix of pairs of brains
correlation_dist = pdist(rho_all_matrix, 'correlation');
correlation_dist_results = squareform(correlation_dist);

% write matrices
csvwrite('seed_based_insula_euclidean_distance_matrix.txt',eucl_dist_results)
csvwrite('seed_based_insula_cosine_distance_matrix.txt',cosine_dist_results)
csvwrite('seed_based_insula_correlation_distance_matrix.txt',correlation_dist_results)

% clean the workspace
clear k rho rho_vect
clear eucl_dist cosine_dist correlation_dist

