
% Before using the NBS toolbox, create a design matrix organised in the same order as the connectivity matrices
% Usually that is alphabetical order. 1 0 is che code for one group and 0 1 for the other, for example:
% 1 0
% 0 1
% 0 1
% 1 0


% set the path of NBS toolbox in matlab and then start the NBS
addpath("/home/imaging/tools/Matlab_toolboxes/NBS1.2/")
addpath("/home/imaging/tools/Matlab_toolboxes/NBS1.2/icons/")
NBS


% set the path of the connectivity matrices previously calculated and set the appropriate t-threshold (usually t=3.1)


%%%%%%%%%%% HYPER-CONNECTIVITY %%%%%%%%%%%%%%%%

% set this contrast for hyper-connectivity
[1,-1] for hyper-connectivity

% run NBS

% This generates a text file containing a binary connectivity matrix NBS-corrected for
% the first significant network for hyper-connectivity. this can be also used as the file.edges for BrainNet
global nbs; ttest_bin_hyper = nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}';
dlmwrite('ttest_bin_hyper_3.1.csv',full(ttest_bin_hyper),'delimiter',',','precision','%d');


% This generates a text file containing a connectivity matrix with t-scores.
global nbs; ttest_test_stat=nbs.NBS.test_stat;
dlmwrite('ttest_test_stat.csv', full(ttest_test_stat),'delimiter',',','precision','%d');



%%%%%%%%%%% HYPO-CONNECTIVITY %%%%%%%%%%%%%%%%

% set this contrast for hypo-connectivity
[-1,1] for hypo-connectivity

% run NBS

% This generates a text file containing a binary connectivity matrix NBS-corrected for
% the first significant network for hypo-connectivity.
global nbs; ttest_bin_hypo = nbs.NBS.con_mat{1}+nbs.NBS.con_mat{1}';
dlmwrite('ttest_bin_hypo_3.1.csv',full(ttest_bin_hypo),'delimiter',',','precision','%d');



%%%%%%%%%%% HYPO- AND HYPER-CONNECTIVITY %%%%%%%%%%%%%%%%

% This generates a text file containing a binary connectivity matrix NBS-corrected for
% the first significant network for either hypo or hyper-connectivity.
ttest_bin_hypo_hyper = full(ttest_bin_hypo) + full(ttest_bin_hyper);


% This generates a text file containing a connectivity matrix with t-scores thresholded with the NBS.
ttest_test_stat_nbs_corrected = ttest_test_stat.*ttest_bin_hypo_hyper;
dlmwrite('ttest_test_stat_nbs_corrected_3.1.csv', full(ttest_test_stat_nbs_corrected),'delimiter',',','precision','%d');











