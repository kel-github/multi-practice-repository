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
        data_dir = '/Volumes/HouseShare/multi-dcm-out/dcm_analysis_vAnat'; % location of subject folders of dcm data
        dat_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_figs';
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
        data_dir = '/media/kgarner/HouseShare/multi-dcm-out/dcm_analysis_vAnat'; % location of subject folders of dcm data
        dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  =  '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_figs';
end
%%%%% STEPS: 
%%%%% 1. perform some basic checks on the dcm models using both the
%%%%% spm_dcm_fmri_check function, and get the R^2 
%%%%% across all subs and models, using the custom written function
%%%%% (initially written just to compare whether data was better accounted
%%%%% for when using a liberal or stringent criteria for auto-ROI selection

%%%%% 2. Define model space and family space for the first question on
%%%%% model space - do modulatory inputs occur via putamen or lipl?
%%%%% after definition of the model and family space, call batch file to
%%%%% run the family comparions. Output figures are manually saved

%%%%% 3. Define model space, family and answer second question (ie. run batch) on model
%%%%% space - does multitasking modulate
%%%%% corticocortical/subcortical-cortical or all 3? Output figures are
%%%%% manually saved according to notes. BMA also performed at this step to
%%%%% answer subsequent questions.

%%%%% 4. BMA over winning family is then used to determine whether any
%%%%% parameters can be excluded from the final network

%%%%% 5. Control analysis - BMA over winning family is conducted for the
%%%%% practice and the control groups - to assess
%%%%% pre-existing differences in the baseline session. p-value computed
%%%%% for one connection that shows differences 

%%%%% 6. Parameters are extracted at the individual subject level and saved
%%%%% to .csv for further analysis

% subject exclusion notes
% 102, - voxels did not survive correction 
% 124, - voxels did not survive correction
% 128, - missing data
% 138, - missing data
% 203, - voxels did not survive correction
% 223, - missing data
% 233, - voxels did not survive correction
% 250  - voxels did not survive correction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. perform some basic checks on the dcm models
% this code can be run to perform some basic checks on the models across
% subs
% i.e. how much of the variance is accounted for, are parameters reliably 
% different from 0? etc
% code calls spm function to generate an interactive plot -
sub_nums     = [101, 103:123, 125:127, 129:137, 139:150, 201:202, 204:222, 224:232, 234:249];
model_stem   = {'DCM_LPut_inp_mat%d.mat'};
sub_fol      = 'sub_%d_out_anatROI_initGLM';
model_nums = 45:63;
run_dcm_checks(sub_nums, sub_fol, data_dir, model_nums, model_stem)

% get total variance explained using custom function
model_stems   = {'DCM_LPut_inp_mat%d.mat', 'DCM_LIPL_inp_mat%d.mat'};
sub_fol      = 'sub_%d_out_anatROI_initGLM/DCM_OUT';
n_mods       = 63; 
var = get_total_variance(sub_nums, model_stems, n_mods, data_dir, sub_fol);
% R^2 with these settings = .1313
%%%% overall checks show that some subjects are fairly well accounted for (~20% variance),
%%%% while some subjects are not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Define model space for all models/subs, and compare between input
% families using custom written function
% define output data folder (to load the defined b-matrices and get number
% of models)
load([dat_fol '/b_mats_v3.mat']);
tmp_subs = sub_nums; 
fnames   = {'DCM_LIPL_inp_mat%d.mat', 'DCM_LPut_inp_mat%d.mat'};
ms       = size(b_mats,3);
base     = data_dir;
mfname   = ([dat_fol '/input_family_comparison/all_subs_allmodels_input_test']);
get_model_space_filenames_v2(tmp_subs, fnames, ms, base, mfname);
% define families for input comparison
% defining model space for input comparison
% family 1 = input via left putamen
% family 2 = input via LIPL
a = 1:size(b_mats, 3);
b = size(b_mats, 3)+1:size(b_mats, 3)*2;
family.partition = zeros(1, size(b_mats, 3));
family.partition(a) = 1;
family.partition(b) = 2;
family.names = {'LIPL', 'LPUT'};
save([dat_fol '/input_family_comparison/' 'fam_idxs_q1_input_v1'], 'family');

% run SPM with the following batch to get family comparisons 
% batch1_input_family_comparison_job % uncomment and run to perform batch
% output....
% figures are manually saved in [fig_fol '/input_family_comparison/']
% fig 1:  input_FamilyExceedance.fig  % shows family exceedance
% probabilities
% fig 2:  input_ModelExceedance.fig   % shows model exceedance
% probabilities (but note inference is made at family level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 3. question - does the modulatory influence of practice occur via
% subcortical -> cortical
% cortical -> cortical
% both?
% -- define model space
fnames   = {'DCM_LPut_inp_mat%d.mat'};
ms       = size(b_mats,3);
base     = data_dir;
mfname   = [dat_fol '/connection_family_comparison/all_subs_allmodels_cortconn_test'];
get_model_space_filenames_v2(tmp_subs, fnames, ms, base, mfname);
% -- define family space
% cort conn = LIPL to SMFC
load([dat_fol '/connection_family_comparison/' 'idxs_q2_cortico_v1']);
family.partition = zeros(1, size(b_mats, 3));
family.partition(a) = 1;
family.partition(b) = 2;
family.partition(c) = 3;
family.names = {'no cort', 'no sub', 'all'};
save([dat_fol '/connection_family_comparison/' 'fam_idxs_q2_cortconn_v1'], 'family');
% run SPM with the following batch to get family comparisons and BMA
% batch2_connection_family_comparison_job % uncomment and run to perform batch
% output....
% figures are manually saved in [fig_fol '/connection_family_comparison/']
% fig 1:  input_FamilyExceedance.fig  % shows family exceedance
% probabilities
% fig 2:  input_ModelExceedance.fig   % shows model exceedance
% probabilities (but note inference is made at family level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 4. BMA to reject parameters - here we plot the estimated group level
% distribution for each of the parameters. Any parameter that includes 0 in
% its estimate, we reject/say we are not confident in its presence
%%%%%%%%% BMA OVER WINNING FAMILY
% confidence intervals on mean parameters - are they different from 0
load([dat_fol '/connection_family_comparison/BMS.mat'])
% get a parameters
A_mus       = BMS.DCM.rfx.bma.mEp.A;
a           = BMS.DCM.rfx.bma.a;
A_prctiles  = prctile(a, [2.5, 97.5], 3);
% and b parameters
B_mus       = BMS.DCM.rfx.bma.mEp.B(:,:,2);
b           = squeeze(BMS.DCM.rfx.bma.b(:,:,2,:));
B_prctiles  = prctile(b, [2.5, 97.5], 3);

%%%%%% code to plot histograms for each connection, with mu and CIs as 
%%%%%% dotted lines

%%% some standard things
x_range = [-.25, .5];
titles = {'LIPL to LPut', 'LIPL to SMFC', 'LPut to LIPL', 'LPut to SMFC', ...
          'SMFC to LIPL', 'SMFC to LPut'};
idx = [4, 7, 2, 8, 3, 6];     
rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];

%%%%% plot a parameters
top_tit = {'A parameters'};
plot_grp_level_params(a, idx, rows, cols, A_mus, A_prctiles, x_range, titles, top_tit)
% all A parameters are statistically different from 0, except from LIPL->SMFC
saveas(gcf, [fig_fol '/connection_family_comparison/BMA_a_params.png']);
%%%%% plot b parameters
top_tit = {'B parameters'};
plot_grp_level_params(b, idx, rows, cols, B_mus, B_prctiles, x_range, titles, top_tit)
% all B parameters are statistically different from 0, except from LIPL->SMFC
saveas(gcf, [fig_fol '/connection_family_comparison/BMA_b_params.png']);
% final model =
% A        [1 1 1;
%           1 1 1;
%           0 1 1];
% B        [0 1 1;
%           1 0 1;
%           0 1 0]
% C        [0 1 0]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 5. BMA at the group level to determine the presence/absence of group
% differences (control analysis)
%%%%%%%% here I am re-running bma at the group level, to test whether there
%%%%%%%% are any pre-training differences between groups
s1_sub_nums = [101, 103:123, 125:127, 129:137, 139:150];
s2_sub_nums = [201:202, 204:222, 224:232, 234:249];
mfname      = [dat_fol '/connection_family_comparison/control_analyses/' 'train_grp_allmodels_cortconn_test'];
get_model_space_filenames_v2(s1_sub_nums, fnames, ms, base, mfname);
mfname      = [dat_fol '/connection_family_comparison/control_analyses/' 'ctrl_grp_allmodels_cortconn_test'];
get_model_space_filenames_v2(s2_sub_nums, fnames, ms, base, mfname);
% run batches on both groups as occured previously in step 3 (except now
% performed on each group separately
% batch3_trngrp_ctrlAnalysis_job
% batch4_ctrlgrp_ctrlAnalysis_job
%%%% now extract and plot a and b parameters by group
trn_bms_fname = [dat_fol '/connection_family_comparison/control_analyses/' 'trn_BMS/BMS.mat'];
[trn_a, trn_a_mus, trn_a_prctiles, trn_b, trn_b_mus, trn_b_prctiles] = get_grpLevel_params_by_grp(trn_bms_fname);
ctrl_bms_fname = [dat_fol '/connection_family_comparison/control_analyses/' 'ctrl_BMS/BMS.mat'];
[ctrl_a, ctrl_a_mus, ctrl_a_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles] = get_grpLevel_params_by_grp(ctrl_bms_fname);
%%%% plot each group

x_range = [-.4, .4];
titles = {'LIPL to LPut', 'LIPL to SMFC', 'LPut to LIPL', 'LPut to SMFC', ...
          'SMFC to LIPL', 'SMFC to LPut'};
idx = [4, 7, 2, 8, 3, 6];     
rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];

%%%%% which vals to plot?
top_tit = {'S1 A parameters (sub level) - by groups'};
plot_grp_level_by_grp(idx, rows, cols, trn_a, trn_a_mus, trn_a_prctiles, ctrl_a, ctrl_a_mus, ctrl_a_prctiles, x_range, titles, top_tit)
saveas(gcf, [fig_fol '/connection_family_comparison/control_analyses/a_params_by_sub_by_grp.png']);
top_tit = {'S1 B parameters (sub level) - by groups'};
x_range = [-.8, .8];
plot_grp_level_by_grp(idx, rows, cols, trn_b, trn_b_mus, trn_b_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles, x_range, titles, top_tit)
saveas(gcf, [fig_fol '/connection_family_comparison/control_analyses/b_params_by_sub_by_grp.png']);
%%%%%%% a parameters are clearly different between groups - can take
%%%%%%% differences to check whether the differences are comparable to the
%%%%%%% second round of modelling (s1 -> s2)
%%%%%%% of the b-parameters - only the LIPL->SMFC b parameter shows a group
%%%%%%% difference (i.e. training group mean is outside of the 95% CIs for
%%%%%%% the control group) 
% save group level parameter estimates so that differences can be compared
% to differences found when modelling the influence of training (s1->s2)
save([dat_fol '/connection_family_comparison/control_analyses/grp_Params_by_grp.mat'], ...
     'trn_a', 'trn_a_mus', 'trn_a_prctiles', 'trn_b', 'trn_b_mus', 'trn_b_prctiles', ...
     'ctrl_a','ctrl_a_mus','ctrl_a_prctiles','ctrl_b','ctrl_b_mus','ctrl_b_prctiles');
%%%%%%% compute the probability of the observed differences, given a
%%%%%%% permuted null distribution
load([dat_fol '/connection_family_comparison/control_analyses/grp_Params_by_grp.mat']);
n = 10000;
out_dists = zeros(3, 3, n);

for i = 1:length(rows)
    out_dists(rows(i), cols(i), :) = permute_params_for_two_sample_test(squeeze(trn_b(rows(i), cols(i), :))', ...
                                                                        squeeze(ctrl_b(rows(i), cols(i), :))', n);
end
%%%%%%% Plot permuted null distribution with observed difference using custom
%%%%%%% function
top_tit = {'Observed group difference against permuted null differences'};
x_range = [-.2, .2];
plot_grp_diffs_w_nulls(idx, rows, cols, out_dists, trn_b_mus, ctrl_b_mus, x_range, titles, top_tit);
saveas(gcf, [fig_fol '/connection_family_comparison/control_analyses/S1_multi_observed_grp_diff_against_permuted_null.png']);

%%%%%% final check - get total variance explained per group for the
%%%%%% cortconn grp (to make sure differences in variability accounted for
%%%%%% isn't a candidate for driving effects)
model_stems   = {'DCM_LPut_inp_mat%d.mat'};
n_mods        = 63;
tg_var        = get_total_variance(sub_nums(sub_nums<200), model_stems, n_mods, data_dir, sub_fol);
cg_var        = get_total_variance(sub_nums(sub_nums>199), model_stems, n_mods, data_dir, sub_fol);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 6: extract subject b parameters for individual differences analysis
% LOAD BMS FILE
load([dat_fol '/connection_family_comparison/BMS.mat'])
idx = [4, 7, 2, 8, 3, 6];     
m =[2, 1, 3, 1, 2];
n =[1, 2, 2, 3, 3];
z = 2;
bs_by_sub = get_b_params_by_sub(BMS, m, n, z, sub_nums);
bsub_fid = fopen([dat_fol '/behav_correlations/sub_b_params.csv'], 'w');
fprintf( bsub_fid, '%3s,%3s,%3s,%1s\n', 'sub', 'grp', 'con', 'b'); 
fprintf( bsub_fid, '%d,%d,%d,%.4f\n', bs_by_sub' );
 
  