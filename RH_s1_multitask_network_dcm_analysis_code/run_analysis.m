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
        data_dir = '~/Documents/RH_s1_MODELS_OUT'; % location of subject folders of dcm data
        dat_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1_multitask_network_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1_multitask_network_dcm_analysis_figs';
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
        % data_dir = '/media/kgarner/HouseShare/multi-dcm-out/dcm_analysis_vAnat'; % location of subject folders of dcm data
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
%%%%% pre-existing differences in the baseline session.Groups are compared
%%%%% using spm_Ncdf (see
%%%%% https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;73bcb3cd.1511)

%%%%% 6. Parameters are extracted at the individual subject level and saved
%%%%% to .csv for further analysis

% subject exclusion notes
% RH: just 128 & 203 are removed for this analysis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START CODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. id who has an output file and define model spaces for subs and groups
% first, cget subs who have a DCM output file
sub_nums = [101:150, 201:250];
rm_idx = [];
for i = 1:length(sub_nums)  
    tmp_fname = sprintf([data_dir '/sub_%d_out_anatROI_initGLM/DCM_OUT/DCM_LPut_inp_mat10.mat'], sub_nums(i));
    if exist(tmp_fname)
    else
        rm_idx = [rm_idx i];
    end   
end
rm_subs = sub_nums(rm_idx);
sub_nums(rm_idx) = [];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% perform some basic checks on the dcm models
% this code can be run to perform some basic checks on the models across
% subs
% i.e. how much of the variance is accounted for, are parameters reliably 
% different from 0? etc
% code calls spm function to generate an interactive plot -
model_stem   = {'DCM_LPut_inp_mat%d.mat'};
sub_fol      = 'sub_%d_out_anatROI_initGLM';
model_nums = 45:63;
run_dcm_checks(sub_nums, sub_fol, data_dir, model_nums, model_stem);
sess_peaks = get_participant_peaks(sub_nums, data_dir, sub_fol); %%%%%
%NEED TO RE-DO THIS 
save([dat_fol '/s1_multi_network_sub_peaks'], 'sess_peaks');
% get total variance explained using custom function
model_stems   = {'DCM_LPut_inp_mat%d.mat', 'DCM_LIPL_inp_mat%d.mat'};
sub_fol      = 'sub_%d_out_anatROI_initGLM/DCM_OUT';
n_mods       = 63; 
var = get_total_variance(sub_nums, model_stems, n_mods, data_dir, sub_fol);
% R^2 with these settings = .0956
% extract participant peaks using custom function and save in the out data


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
mfname   = ([dat_fol '/input_family_comparison/all_subs_allmodels_input_test.mat']);
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
batch2_connection_family_comparison_job % uncomment and run to perform batch
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
A_stds      = BMS.DCM.rfx.bma.sEp.A;
a           = BMS.DCM.rfx.bma.a;
A_prctiles  = prctile(a, [.4, 99.6], 3); % Sidak
% and b parameters
B_mus       = BMS.DCM.rfx.bma.mEp.B(:,:,2);
B_stds      = BMS.DCM.rfx.bma.sEp.B(:,:,2);
b           = squeeze(BMS.DCM.rfx.bma.b(:,:,2,:));
B_prctiles  = prctile(b, [.4, 99.6], 3);

%%%%%% code to plot histograms for each connection, with mu and CIs as 
%%%%%% dotted lines

%%% some standard things
x_range = [-.25, .5];
titles = {'RIPL to RPut', 'RIPL to SMFC', 'RPut to RIPL', 'RPut to SMFC', ...
          'SMFC to RIPL', 'SMFC to RPut'};
idx = [4, 7, 2, 8, 3, 6];     
rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];

%%%% get the probability that the a and b parameters overlap with zero
b_test = compare_grp_vs_zero(rows, cols, B_mus, B_stds);
var_idx = [2, 3, 4, 6, 7, 8]; % index of elements of the participant b matrix that should be
% included in the correlation matrix
% [~,bMeff,balpha] = Meff_correction(BMS.DCM.rfx.bma.mEps, var_idx, 1);
% balpha = .0087; tsk, used random effects info to compute this. Not using
% as not 100% sure its right
% criteria = > 0.9913
% or Sidak: (1-.05)^(1/6): 0.9915
% IPL -> Put, IPL -> SMFC, Put -> IPL, Put -> SMFC, SMFC -> IPL, SMFC -> Put 
% LH:
% 0.9322      0.8844       1.0000      0.9617       0.8190       0.9774
% N           N            Y           N            N            N
% RH:  
% 0.9764      0.8769       0.9976      1.0000       0.9295       1.0000
% N           N            Y           Y            N            Y
a_test = compare_grp_vs_zero(rows, cols, A_mus, A_stds);
% [~,aMeff,aalpha] = Meff_correction(BMS.DCM.rfx.bma.mEps, var_idx, 2);
% aalpha = .0093
% criteria = > .0.9915
% LH
% 1.0000    0.9795    1.0000    1.0000    1.0000    0.6612
% RH
% 1.0000    1.0000    1.0000    1.0000    1.0000    1.0000


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
%           1 1 0;
%           0 1 1];
% B        [0 1 0;
%           0 0 0;
%           0 0 0]
% C        [0 1 0]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 5. BMA at the group level to determine the presence/absence of group
% differences (control analysis)
%%%%%%%% here I am re-running bma at the group level, to test whether there
%%%%%%%% are any pre-training differences between groups
s1_sub_nums = sub_nums(sub_nums <= 150);
s2_sub_nums = sub_nums(sub_nums > 150);
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
[trn_a, trn_a_mus, trn_a_prctiles, trn_b, trn_b_mus, trn_b_sds, trn_b_prctiles] = get_grpLevel_params_by_grp(trn_bms_fname);
ctrl_bms_fname = [dat_fol '/connection_family_comparison/control_analyses/' 'ctrl_BMS/BMS.mat'];
[ctrl_a, ctrl_a_mus, ctrl_a_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_sds, ctrl_b_prctiles] = get_grpLevel_params_by_grp(ctrl_bms_fname);
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
%%%%%%% no strong differences between groups
% save group level parameter estimates so that differences can be compared
% to differences found when modelling the influence of training (s1->s2)
save([dat_fol '/connection_family_comparison/control_analyses/grp_Params_by_grp.mat'], ...
     'trn_a', 'trn_a_mus', 'trn_a_prctiles', 'trn_b', 'trn_b_mus', 'trn_b_sds', 'trn_b_prctiles', ...
     'ctrl_a','ctrl_a_mus','ctrl_a_prctiles','ctrl_b','ctrl_b_mus', 'ctrl_b_sds', 'ctrl_b_prctiles');
%%%%%%% compute the probability of the observed differences, 
load([dat_fol '/connection_family_comparison/control_analyses/grp_Params_by_grp.mat']);
%%%%%%% compute the probability of a group difference on each parameter
n = [2, 1, 3, 1, 2];
m = [1, 2, 2, 3, 3];
pps = compare_grps_posts(n, m, trn_b_mus, trn_b_sds, ctrl_b_mus, ctrl_b_sds);
%%% all probabilities are < .99 - so not significant

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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extra analysis steps in light of diff results to LH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% question - does the modulatory influence of practice occur via
% subcortical -> cortical
% cortical -> cortical
% both?
% -- define model space - this time including all models from both
% families, as we did not have evidence to favour one input family over the other
load([dat_fol '/b_mats_v3.mat']);
tmp_subs = sub_nums; 
fnames   = {'DCM_LPut_inp_mat%d.mat', 'DCM_LIPL_inp_mat%d.mat'};
ms       = size(b_mats,3);
base     = data_dir;
mfname   = [dat_fol '/both_inputs_connection_comparison/all_subs_bothinputs_allmodels_cortconn_test'];
get_model_space_filenames_v2(tmp_subs, fnames, ms, base, mfname);


% make a family structure same as in step 3 above, just this time
% concatenate it so it runs twice, so that it encompasses both sets of
% models (i.e. Input -> Put or input -> LIPL)
load([dat_fol '/connection_family_comparison/' 'idxs_q2_cortico_v1']);
family.partition = zeros(1, size(b_mats, 3));
family.partition(a) = 1;
family.partition(b) = 2;
family.partition(c) = 3;
family.names = {'no cort', 'no sub', 'all'};
family.partition = [family.partition family.partition];
save([dat_fol '/both_inputs_connection_comparison/' 'fam_idxs_q2_cortconn_v1'], 'family');

% run batch
% batch5_bothinputs_connection_family_comparison.mat % batch job
% output....
% figures are manually saved in [fig_fol '/connection_family_comparison/']
% fig 1:  input_FamilyExceedance.fig  % shows family exceedance
% probabilities
% fig 2:  input_ModelExceedance.fig   % shows model exceedance
% probabilities (but note inference is made at family level)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BMA to reject parameters - here we plot the estimated group level
% distribution for each of the parameters. Any parameter that includes 0 in
% its estimate, we reject/say we are not confident in its presence
%%%%%%%%% BMA OVER WINNING FAMILY
% confidence intervals on mean parameters - are they different from 0
load([dat_fol '/both_inputs_connection_comparison/BMS.mat'])
% get a parameters
A_mus       = BMS.DCM.rfx.bma.mEp.A;
A_stds      = BMS.DCM.rfx.bma.sEp.A;
a           = BMS.DCM.rfx.bma.a;
A_prctiles  = prctile(a, [.4, 99.6], 3); % Sidak
% and b parameters
B_mus       = BMS.DCM.rfx.bma.mEp.B(:,:,2);
B_stds      = BMS.DCM.rfx.bma.sEp.B(:,:,2);
b           = squeeze(BMS.DCM.rfx.bma.b(:,:,2,:));
B_prctiles  = prctile(b, [.4, 99.6], 3);

%%%%%% code to plot histograms for each connection, with mu and CIs as 
%%%%%% dotted lines

%%% some standard things
x_range = [-.25, .5];
titles = {'RIPL to RPut', 'RIPL to SMFC', 'RPut to RIPL', 'RPut to SMFC', ...
          'SMFC to RIPL', 'SMFC to RPut'};
idx = [4, 7, 2, 8, 3, 6];     
rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];

%%%% get the probability that the a and b parameters overlap with zero
b_test = compare_grp_vs_zero(rows, cols, B_mus, B_stds);
% Sidak: (1-.05)^(1/6): 0.9915
% IPL -> Put, IPL -> SMFC, Put -> IPL, Put -> SMFC, SMFC -> IPL, SMFC -> Put 
% LH:
% 0.9322      0.8844       1.0000      0.9617       0.8190       0.9774
% N           N            Y           N            N            N
% RH:  
% 0.9764      0.8769       0.9976      1.0000       0.9295       1.0000
% N           N            Y           Y            N            Y
% RH BOTH INPUTS
% 0.9448      0.9998       0.5993      0.9955       0.9947       0.9881
% N           Y            N           Y            Y            N
a_test = compare_grp_vs_zero(rows, cols, A_mus, A_stds);
% criteria = > .0.9915
% LH
% 1.0000    0.9795    1.0000    1.0000    1.0000    0.6612
% RH
% 1.0000    1.0000    1.0000    1.0000    1.0000    1.0000
% RH
% 1.0000    1.0000    1.0000    1.0000    1.0000    1.0000
















