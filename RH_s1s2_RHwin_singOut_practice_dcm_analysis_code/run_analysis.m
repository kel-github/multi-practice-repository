%%%%% written by K. Garner - June 2018 
%%%%% To-do
%%%%% 1. link to data on RDM system

%%%%% WHAT THIS CODE DOES:
%%%%% this code runs the DCM analysis applied to session 1&2 multitasking
%%%%% data, with single trials regressed out (i.e. influence of practice
%%%%% on multitask trials)
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
        data_dir = '~/Documents/RH_s1s2_RHWin_MULTTRIALS_MODELS_OUT'; % location of subject folders of dcm data; % location of subject folders of dcm data
        dat_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1s2_RHwin_singOut_practice_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1s2_RHwin_singOut_practice_dcm_analysis_figs';
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
%        data_dir = '/media/kgarner/KG_MRI_PROC/s2_MULTTRIALS_MODELS_OUT'; % location of subject folders of dcm data% location of subject folders of dcm data
%         dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_singOut_practice_dcm_analysis_outdata'; % location of outputs for this analysis
%         fig_fol  =  '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_singOut_practice_dcm_analysis_figs';
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
%%%%% 4. Perform tests on group level b parameters to determine
%%%%% whether the observed difference is statistically different from 0
%%%%% 6. Extract b parameters for individual differences analysis

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. id who has an output file and define model spaces for subs and groups
% first, cget subs who have a DCM output file
sub_nums = [101:150, 201:250];
rm_idx = [];
for i = 1:length(sub_nums)  
    % note: although the title has LPut in it - it is actually RPut in this
    % case
    tmp_fname = sprintf([data_dir '/sub_%d_out_s1s2_anatROI_initGLM_RHWin_regOutSing_RH/DCM_OUT/DCM_RPut_inp_winb_prac10.mat'], sub_nums(i));
    
    if exist(tmp_fname)
    else
        rm_idx = [rm_idx i];
    end   
end
rm_subs = sub_nums(rm_idx);
sub_nums(rm_idx) = [];

% sub 102, 104, 106, 128, 138, 144, 203, % are missing models - see s1 and s1s2, as
% is 106 (in addition to the LH analysis)
% single trials
sub_fol = 'sub_%d_out_s1s2_anatROI_initGLM_RHWin_regOutSing_RH';
sess_peaks = get_participant_peaks(sub_nums, data_dir, sub_fol);
save([dat_fol '/s1s2_regOutsing_sub_peaks'], 'sess_peaks');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Define model space for all models/subs, and compare between input
% families using custom written function
% define output data folder (to load the defined b-matrices and get number
% of models)
load([dat_fol '/b_mats_v3.mat']);
tmp_subs = sub_nums; 
fnames   = {'DCM_RIPL_inp_winb_prac%d.mat', 'DCM_RPut_inp_winb_prac%d.mat'};
ms       = 1:size(b_mats,3);
base     = data_dir;
mfname   = ([dat_fol '/input_family_comparison/all_subs_allmodels_input_test.mat']);
get_model_space_filenames_v3(tmp_subs, fnames, ms, base, mfname);

% run SPM with the following batch to get family comparisons 
% batch1_input_family_comparison_job % uncomment and run to perform batch
% output....
% figures are manually saved in [fig_fol '/input_family_comparison/']
% fig 1:  input_FamilyExceedance.fig  % shows family exceedance
% probabilities
% fig 2:  input_ModelExceedance.fig   % shows model exceedance
% probabilities (but note inference is made at family level)

% NO PARTICULAR INPUT FAMILY WON - SO COMBINING FOR THE NEXT STAGE:

%%%% now get model space filename for group 1 BMS
g1_sub_nums = sub_nums(sub_nums < 200);
tmp_subs    = g1_sub_nums;
fnames   = {'DCM_RIPL_inp_winb_prac%d.mat', 'DCM_RPut_inp_winb_prac%d.mat'};
ms       = 1:size(b_mats,3);
base     = data_dir;
mfname   = [dat_fol '/train/train_allmodels_s1s2_s1winB_singRegOut'];
get_model_space_filenames_v3(g1_sub_nums, fnames, ms, base, mfname);

% same for group 2
g2_sub_nums = sub_nums(sub_nums > 200);
mfname   = [dat_fol '/control/control_allmodels_s1s2_s1winB_singRegOut'];
get_model_space_filenames_v3(g2_sub_nums, fnames, ms, base, mfname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% next question - does the modulatory influence of practice occur via
% subcortical -> cortical
% cortical -> cortical
% both?
% -- define model space for each group, run BMS & BMA over winning family
% 2. Perform BMS/BMA on each group with cortconn fams - check for clear winners (if any)
% run SPM with the following batch to get family comparisons and BMA
% output figs saved manually at
% batch2_train_BMA_job % uncomment to run
% output figs saved manually at 
% [fig_fol 'train/train_conFamExceedance.fig']
% [fig_fol 'train/train_conModExceedance.fig']
% batch2_control_BMA_job % uncomment to run
% [fig_fol 'control/ctrl_conFamExceedance.fig']
% [fig_fol 'control/ctrl_conModExceedance.fig']
% There are some differences between groups in terms of favoured model
% structures, but overall most complex models are winning
% - however as many model features are similar, will conduct BMA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Plot posteriors for all subs, and then for each group, each group for comparisons between and against 0
% first extract parameters
trn_bms_fname = [dat_fol '/train/' 'BMS.mat'];
[trn_a, trn_a_mus, trn_a_prctiles, trn_b, trn_b_mus, trn_b_sds, trn_b_prctiles] = get_grpLevel_params_by_grp_v2(trn_bms_fname,2);
ctrl_bms_fname = [dat_fol '/control/' 'BMS.mat'];
[ctrl_a, ctrl_a_mus, ctrl_a_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_sds, ctrl_b_prctiles] = get_grpLevel_params_by_grp_v2(ctrl_bms_fname,2);
% now plot b's
titles = {'RIPL to RPut', 'RIPL to SMFC', 'RPut to RIPL', 'RPut to SMFC', ...
          'SMFC to RIPL', 'SMFC to RPut'};
idx = [4, 7, 2, 8, 3, 6];

rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];
top_tit = {'S1 B parameters (sub level) - by groups'};
x_range = [-.8, .8];
plot_grp_level_by_grp(idx, rows, cols, trn_b, trn_b_mus, trn_b_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles, x_range, titles, top_tit)
saveas(gcf, [fig_fol '/BMA_b_params_by_grp.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Test for group differences on included connections
rows = [2, 3, 1, 3, 1, 2];
cols = [1, 1, 2, 2, 3, 3];
train_pps = compare_grp_vs_zero(rows, cols, trn_b_mus, trn_b_sds);
% for the training group, only the LPut -> SMFC
% connection survive corrections for multiple comparisons 
% Sidak w 6 = > .9915

% LH: 0.8656    0.8721    0.9891    0.5223 % LPut to SMFC is different
% RH -  0.9518    0.9998    0.7681    0.7930    0.6084    0.8315 row 3, col
% 1, RIPL -> SMFC is sig diff from zero
% RPut to SMFC)
%  % RIPL to SMFC
%  is modulated by practice for the practice group

control_pps = compare_grp_vs_zero(rows, cols, ctrl_b_mus, ctrl_b_sds);
% for the control group, only the LPut -> SMFC connection survives correction
% LH: 0.5996    0.9293    1.0000    0.8328
% RH: 0.9660    0.9666    0.8003    1.0000    0.7767    0.7950 % RPut to
% SMFC is significant
pps = compare_grps_posts(rows, cols, trn_b_mus, trn_b_sds, ctrl_b_mus, ctrl_b_sds); % no sig differences
% LH: 0.7194    0.5989    0.9983    0.7609
% RH: 0.6193    0.8148    0.8645    0.9657    0.6074    0.5050 % nsig diff
% between groups
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Extract b parameters for individual differences analysis
idx = [4, 2, 8, 3];     
rows = [2, 3, 1, 3, 1, 2];
cols = [1, 1, 2, 2, 3, 3];
z = 2;
% LOAD BMS FILE
load([dat_fol '/train/BMS.mat'])
bs_by_sub = get_b_params_by_sub(BMS, rows, cols, z, g1_sub_nums);
clear BMS
load([dat_fol '/control/BMS.mat'])
tmp = get_b_params_by_sub(BMS, rows, cols, z, g2_sub_nums);  
bs_by_sub = [bs_by_sub; tmp];
bsub_fid = fopen([dat_fol '/behav_correlations/sub_b_params.csv'], 'w');
fprintf( bsub_fid, '%3s,%3s,%3s,%1s\n', 'sub', 'grp', 'con', 'b'); 
fprintf( bsub_fid, '%d,%d,%d,%.4f\n', bs_by_sub' );


