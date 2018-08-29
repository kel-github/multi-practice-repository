%%%%% written by K. Garner - June 2018 
%%%%% To-do
%%%%% 1. link to data on RDM system

%%%%% WHAT THIS CODE DOES:
%%%%% this code runs the DCM analysis applied to session 1 multitasking
%%%%% data
%%%%% links to data here: 
%%%%% subject-level dcm output files:
%%%%% output data from this analysis:

%%%%% NOTE: walking through this code should be sufficient to understand how the
%%%%% analysis was run - but if you want to repeat the analysis steps you
%%%%% will need to...
%%%%% change the following paths to match your local setup.
PLACE = 'home';

switch PLACE
    case 'home'
        
        addpath('~/Documents/MATLAB/spm12');
        data_dir = '/Volumes/HouseShare/multi-dcm-out/dcm_s1s2_s1Win'; % location of subject folders of dcm data
        dat_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mt_practice_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mt_practice_dcm_analysis_figs';
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
        data_dir = '/media/kgarner/HouseShare/multi-dcm-out/dcm_s1s2_s1Win'; % location of subject folders of dcm data
        dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mt_practice_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  =  '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mt_practice_dcm_analysis_figs';
end

%%%% STEPS:
%%%%% 1. identify who has a DCM output file and who does not. Create model
%%%%% space filenames for both groups and save
%%%%% 2. Perform bayesian model averaging for each group - at this point
%%%%% can check model evidences to see if there is one clear winner for
%%%%% each group, if not, proceed to estimated posteriors over groups to
%%%%% compare against 0 and each other
%%%%% 3. Plot posterior estimates over patameters for each group, for group
%%%%% based comparisons
%%%%% 4. Perform permutation tests on group level b parameters to determine
%%%%% whether the observed difference is statistically different from 0
%%%%% 5. Plot the differences
%%%%% 6. Extract b parameters for individual differences analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. id who has an output file and define model spaces for subs and groups
% first, cget subs who have a DCM output file
sub_nums = [101:150, 201:250];
rm_idx = [];
for i = 1:length(sub_nums)  
    tmp_fname = sprintf([data_dir '/sub_%d_out_s1s2_anatROI_initGLM/DCM_OUT/DCM_LPut_inp_winb_prac10.mat'], sub_nums(i));
    if exist(tmp_fname)
    else
        rm_idx = [rm_idx i];
    end   
end
rm_subs = sub_nums(rm_idx);
sub_nums(rm_idx) = [];
% sub 102, 106, 128, 138, 203, 209, 223, % are missing models - see s1
% run_analysis.m for notes on missing data, remaining would not have had
% sig voxels id'd by new first level glm

%%%% now get model space filename for group 1 BMS
g1_sub_nums = sub_nums(sub_nums < 200);
tmp_subs    = g1_sub_nums;
fnames   = {'DCM_LPut_inp_winb_prac%d.mat'};
ms       = 1:31;
base     = data_dir;
mfname   = [dat_fol '/train/train_allmodels_s1s2_s1winB'];
get_model_space_filenames_v3(g1_sub_nums, fnames, ms, base, mfname);

% same for group 2
g2_sub_nums = sub_nums(sub_nums > 200);
mfname   = [dat_fol '/control/control_allmodels_s1s2_s1winB'];
get_model_space_filenames_v3(g2_sub_nums, fnames, ms, base, mfname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Perform BMA on each group - check for clear winners (if any)
% run SPM with the following batch to get family comparisons and BMA
% batch1_train_BMA_job.m % uncomment to run
% output figs saved manually at 
% [fig_fol 'train/train_mPrac_BOR.fig']
% [fig_fol 'train/train_mPract_ModExceedance.fig']
% batch2_control_BMA_job.m % uncomment to run
% [fig_fol 'control/control_mPrac_BOR.fig']
% [fig_fol 'control/control_mPract_ModExceedance.fig']
% There are some differences between groups in terms of favoured model
% structures - however as there is no single clear winner for either group,
% we now look at posteriors over parameters estimated for each group using
% BMA.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Plot posteriors for each group for comparisons between and against 0
% first extract parameters
trn_bms_fname = [dat_fol '/train/' 'BMS.mat'];
[trn_a, trn_a_mus, trn_a_prctiles, trn_b, trn_b_mus, trn_b_prctiles] = get_grpLevel_params_by_grp_v2(trn_bms_fname,3);
ctrl_bms_fname = [dat_fol '/control/' 'BMS.mat'];
[ctrl_a, ctrl_a_mus, ctrl_a_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles] = get_grpLevel_params_by_grp_v2(ctrl_bms_fname,3);
% now plot b's
titles = {'LIPL to LPut', 'LPut to LIPL', 'LPut to SMFC', ...
          'SMFC to LIPL', 'SMFC to LPut'};
idx = [4, 2, 8, 3, 6];     
rows =[2, 1, 3, 1, 2];
cols =[1, 2, 2, 3, 3];
top_tit = {'S1 B parameters (sub level) - by groups'};
x_range = [-.8, .8];
plot_grp_level_by_grp(idx, rows, cols, trn_b, trn_b_mus, trn_b_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles, x_range, titles, top_tit)
saveas(gcf, [fig_fol '/BMA_b_params_by_grp.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Perform permutations of differences between shuffled data to form a
% null distribution on the difference between groups for each parameter
% using custom function written for purpose
n = 10000;
out_dists = zeros(3, 3, n);

for i = 1:length(rows)
    out_dists(rows(i), cols(i), :) = permute_params_for_two_sample_test(squeeze(trn_b(rows(i), cols(i), :))', ...
                                                                        squeeze(ctrl_b(rows(i), cols(i), :))', n);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Plot permuted null distribution with observed difference using custom
% function
top_tit = {'Observed group difference against permuted null difference'};
x_range = [-.5, .1];
plot_grp_diffs_w_nulls(idx, rows, cols, out_dists, trn_b_mus, ctrl_b_mus, x_range, titles, top_tit);
saveas(gcf, [fig_fol '/Observed_grp_diff_against_permuted_null.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Extract b parameters for individual differences analysis
idx = [4, 2, 8, 3, 6];     
m =[2, 1, 3, 1, 2];
n =[1, 2, 2, 3, 3];
z = 3;
% LOAD BMS FILE
load([dat_fol '/train/BMS.mat'])
bs_by_sub = get_b_params_by_sub(BMS, m, n, z, g1_sub_nums);
clear BMS
load([dat_fol '/control/BMS.mat'])
tmp = get_b_params_by_sub(BMS, m, n, z, g2_sub_nums);  
bs_by_sub = [bs_by_sub; tmp];
bsub_fid = fopen([dat_fol '/behav_correlations/sub_b_params.csv'], 'w');
fprintf( bsub_fid, '%3s,%3s,%3s,%1s\n', 'sub', 'grp', 'con', 'b'); 
fprintf( bsub_fid, '%d,%d,%d,%.4f\n', bs_by_sub' );


