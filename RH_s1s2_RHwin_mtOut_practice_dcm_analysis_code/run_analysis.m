%%%%% written by K. Garner - June 2018 
%%%%% To-do
%%%%% 1. link to data on RDM system

%%%%% WHAT THIS CODE DOES:
%%%%% this code runs the DCM analysis applied to session 1&2 multitasking
%%%%% data, with multitask trials regressed out (i.e. influence of practice
%%%%% on single task trials)
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
        data_dir = '~/Documents/RH_s1s2_RHWin_SINGTRIALS_MODELS_OUT'; % location of subject folders of dcm data
        dat_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1s2_RHwin_mtOut_practice_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = '/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1s2_RHwin_mtOut_practice_dcm_analysis_figs';
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
%         data_dir = '/media/kgarner/KG_MRI_PROC/s2_SINGTRIALS_MODELS_OUT'; % location of subject folders of dcm data
%         dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mtOut_practice_dcm_analysis_outdata'; % location of outputs for this analysis
%         fig_fol  =  '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mtOut_practice_dcm_analysis_figs';
end

%%%% STEPS:
%%%%% 1. identify who has a DCM output file and who does not. Create model
%%%%% space filenames for both groups and save
%%%%% 2. Compare group families with input to either RIPL or RPUT. Take winning fam (or both)
%%%%% and compare across connectivity families (as with the initial sess 1 analysis in paper)
%%%%% 3. Perform bayesian model averaging across winnining group for train vs controls 
%%%%% can check model evidences to see if there is one clear winner for
%%%%% each group, if not, proceed to estimated posteriors over groups to
%%%%% compare against 0 and each other
%%%%% 4. Plot posterior estimates over patameters for each group, for group
%%%%% based comparisons
%%%%% 5. Perform tests on group level b parameters to determine
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
    tmp_fname = sprintf([data_dir '/sub_%d_out_s1s2_anatROI_initGLM_RHWin_regOutMult_RH/DCM_OUT/DCM_RPut_inp_winb_prac10.mat'], sub_nums(i));
    if exist(tmp_fname)
    else
        rm_idx = [rm_idx i];
    end   
end
rm_subs = sub_nums(rm_idx);
sub_nums(rm_idx) = [];

% sub 102 , 106 ,  128 ,  138 ,  144 ,  203 % are missing models - see s1, as is 106
% (Additional in the RH analysis)
% run_analysis.m for notes on missing data, remaining (144) did not have 
% sig voxels id'd by new first level glm

% get participant peak coordinates
%run_dcm_checks(sub_nums, sub_fol, data_dir, model_nums, model_stem)
sub_fol = 'sub_%d_out_s1s2_anatROI_initGLM_RHWin_regOutMult_RH';
sess_peaks = get_participant_peaks(sub_nums, data_dir, sub_fol);
save([dat_fol '/s1s2_regOutMult_sub_peaks'], 'sess_peaks');

load([dat_fol '/s1s2_regOutMult_sub_peaks'], 'sess_peaks');
proportion_presma = sum(sess_peaks(:,2,3) > 0)/length(sess_peaks(:,2,3)); % just getting proportion of p's
% for whom the peak was pre sma rather than sma proper (defined as being
% anterior to the origin of the y coordinate - Lee et al 2010, Defining functional SMA and
% pre-SMA subregions in human MFC using resting state fMRI. Neuroimage
% (78%)

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% next question - does the modulatory influence of practice occur via
% subcortical -> cortical
% cortical -> cortical
% both?
% -- define model space for each group, run BMS & BMA over winning family

%fnames   = {'DCM_RIPL_inp_winb_prac%d.mat'};
%ms       = size(b_mats,3);
%base     = data_dir;
%mfname   = [dat_fol '/allsubs/allsubs_allmodels_s1s2_s1winB_multRegOut'];
%get_model_space_filenames_v3(sub_nums, fnames, ms, base, mfname);

%%%% now get model space filename for group 1 BMS
g1_sub_nums = sub_nums(sub_nums < 200);
tmp_subs    = g1_sub_nums;
fnames   = {'DCM_RIPL_inp_winb_prac%d.mat'};
ms       = 1:size(b_mats,3);
base     = data_dir;
mfname   = [dat_fol '/train/train_RIPLmodels_s1s2_s1winBRH_multRegOut'];
get_model_space_filenames_v3(g1_sub_nums, fnames, ms, base, mfname);

% same for group 2
g2_sub_nums = sub_nums(sub_nums > 200);
mfname   = [dat_fol '/control/control_RIPLmodels_s1s2_s1winBRH_multRegOut'];
get_model_space_filenames_v3(g2_sub_nums, fnames, ms, base, mfname);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. Perform BMA on each group - check for clear winners (if any)
% run SPM with the following batch to get family comparisons and BMA
% batch_2_trn_conBMS_winBMA_job % uncomment to run
% output figs saved manually at 
% [fig_fol 'train/train_RHWin_Prac_mOut_conFamExceedance.fig']
% [fig_fol 'train/train_RHWin_Prac_mOut_conFamExceedance.fig']
% batch_3_trn_conBMS_winBMA_job % uncomment to run
% [fig_fol 'control/ctrl_RHWin_Prac_mOut_conFamExceedance.fig']
% [fig_fol 'control/ctrl_RHWin_Prac_mOut_conModExceedance.fig']
% There are some differences between groups in terms of favoured model
% structures - conducting BMA to look over multiple models
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Plot posteriors for all subs, and then for each group, each group for comparisons between and against 0
% first extract parameters
trn_bms_fname = [dat_fol '/train/' 'BMS.mat'];
[trn_a, trn_a_mus, trn_a_prctiles, trn_b, trn_b_mus, trn_b_sds, trn_b_prctiles] = get_grpLevel_params_by_grp_v2(trn_bms_fname,2);
% %trn_b_sub_params = BMS.DCM.rfx.bma.mEps;
ctrl_bms_fname = [dat_fol '/control/' 'BMS.mat'];
[ctrl_a, ctrl_a_mus, ctrl_a_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_sds, ctrl_b_prctiles] = get_grpLevel_params_by_grp_v2(ctrl_bms_fname,2);
% %ctrl_b_sub_params = BMS.DCM.rfx.bma.mEps;
clear BMS
% now plot b's
titles = {'RIPL to RPut', 'RIPL to SMFC', 'RPut to RIPL', 'RPut to SMFC', ...
          'SMFC to RIPL', 'SMFC to RPut'};
idx = [4, 7, 2, 8, 3, 6];

rows =[2, 3, 1, 3, 1, 2];
cols =[1, 1, 2, 2, 3, 3];
top_tit = {'S1 B parameters (sub level) - by groups'};
x_range = [-.8, .8];
% plot_grp_level_params(all_b, idx, rows, cols, all_b_mus, all_b_prctiles, x_range, titles, top_tit)
% saveas(gcf, [fig_fol '/BMA_b_params_over_both_grps.png']);
%%%%%% across all, 1 connection is statistically different to 0 - LPut -> SMFC

plot_grp_level_by_grp(idx, rows, cols, trn_b, trn_b_mus, trn_b_prctiles, ctrl_b, ctrl_b_mus, ctrl_b_prctiles, x_range, titles, top_tit)
saveas(gcf, [fig_fol '/BMA_b_params_by_grp.png']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Test for group differences against 0 and against each other on
% included connections
%%%%%%% against zero
%%%%%%% train grp
%%%% SIDAK = .9915
rows = [2, 3, 1, 3, 1, 2];
cols = [1, 1, 2, 2, 3, 3];
train_pps = compare_grp_vs_zero(rows, cols, trn_b_mus, trn_b_sds);
% LIPL -> Put, Put -> LIPL, Put -> SMFC, SMFC -> LIPL
% 0.9908    0.8279    0.9567    0.7990
%var_idx = [2,4,6,7];
% criteria = sidak > (1-.05)^(1/4) 0.9873
% only LIPL -> Lput is > 0

% RHWin all nsig
%    0.8905    0.9048    0.8172    0.9457    0.6487    0.7588
ctrl_pps = compare_grp_vs_zero(rows, cols, ctrl_b_mus, ctrl_b_sds);
%%%%% same for ctrl group
% LIPL -> Put, Put -> LIPL, Put -> SMFC, SMFC -> LIPL
%  0.7998    0.9967    1.0000    0.5299
% both Put->LIPL, & LPut > SMFC are > 0 

% RH
%  1.0000    1.0000    0.5553    0.5837    0.9555    0.8142
% RIPL -> RPut, RIPL -> SMFC

pps = compare_grps_posts(rows, cols, trn_b_mus, trn_b_sds, ctrl_b_mus, ctrl_b_sds);
% Sidak = > .9873
% 0.9891    0.9959    0.9998    0.7352
% trn > ctrl on LIPL -> Lput, ctrl > trn on Lput -> LIPL, Lput > SMFC

% RH 
% 0.9872    0.9955    0.7522    0.8196    0.9356    0.5753 RIPL -> SMFC is
% significant

save('single_posteriors', 'trn_b_mus', 'trn_b_sds', 'ctrl_b_mus', 'ctrl_b_sds');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6. Extract b parameters for individual differences analysis
idx = [4, 2, 8, 3, 6];     

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


