%%%% written by K. Garner, Oct 2018
%%%% code loads appropriate BMS files (s1|s2 practice multitasking)  
%%%% and plots posterior probabilities for single and multitask trials
%%%% as overlapping histograms - base model and final models are also
%%%% printed and saved
%%%% run this code from the folder that you want to save the figs in, and
%%%% the same folder that contains the plotting function

%%%% STEPS
%%%% set locations
%%%% set aesthetics for posteriors over parameter figs
%%%% load trn & ctrl single task posts, plot in grid form, 
%%%% load trn & ctrl multi task posts
%%%% plot winning models (1 for single task trials, that is the same for
%%%% control multitask trials), and the winning model for train multitask
%%%% trials
%%%% lastly, plot a separate figure that contains the base model for the
%%%% methods figure

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
% LOCATIONS
PLACE = 'qubes';

switch PLACE
    case 'home'
        
        addpath('~/Documents/MATLAB/spm12');
        dat_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/';
        fig_fol  = pwd;
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
        dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/'; % location of outputs for this analysis
        fig_fol  = pwd;
end
st_fol = 's1s2_mtOut_practice_dcm_analysis_outdata/';
mt_fol = 's1s2_singOut_practice_dcm_analysis_outdata/';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTINGS


sig_diff_zero_cols    = [230, 97, 1; ... % trn group
                         94, 60, 153; ...
                         211, 221, 220]; % line colour
face_alpha = 0.9; 

% SUBPLOT SETTINGS 
% %%%%%% THESE SETTINGS PUT THE TWO SETS OF POSTERIORS SIDE BY SIDE
% win_mod_pos = [0.02, 0.26, 0.5, 0.74; ... % lefts
%                .02,  .02,  .02, .02; ... % bottoms
%                repmat(.24, 1, 4); ... % widths
%                repmat(.24, 1, 4)]; % heights

% post_params_trn_pos = [[.08,    .08,    .08, .22,    .22,    .22, .36,   .36, .36];... % lefts
%                        [0.78, 0.64, 0.5, 0.78, 0.64, 0.5, 0.78, 0.64, 0.5];... % bottoms
%                         repmat(.14, 1, 9);... %widths
%                         repmat(.14, 1, 9) ]; % heights
% post_params_mult_pos = [.58, .58, .58, .72, .72, .72, .86, .86, .86;... % lefts
%                        [0.78, 0.64, 0.5, 0.78, 0.64, 0.5, 0.78, 0.64, 0.5];... % bottoms
%                        repmat(.14, 1, 9);... %widths
%                        repmat(.14, 1, 9)]; % heights  

% post_params_trn_pos = [[.08, .21,  .05, .34, .29];... % lefts
%                        [.5,   .5,  .7, .5, .7];... % bottoms
%                         .12, .12,  .2, .12, .2;... %widths
%                         .12, .12,  .2, .12, .2]; % heights
%                     
% post_params_ctrl_pos = [[.08, .21,  .05, .34, .29] + .5;...                    
%                         [.5,   .5,  .7, .5, .7];...
%                         .12, .12,  .2, .12, .2;... %widths
%                         .12, .12,  .2, .12, .2]; % heights    
single_trials_pos = [ [.08, .31, .54, .77]; ...
                      [.7,  .7,  .7,  .7]; ...
                      repmat(.21, 1, 4); ...
                      repmat(.23, 1, 4)      ];
multi_trials_pos  = [ [.08, .31, .54, .77]; ...
                      [.4,  .4,  .4,  .4]; ...
                      repmat(.21, 1, 4); ...
                      repmat(.23, 1, 4)      ];
model_depict_locs = [0.02, 0.26, 0.5, 0.74; ... % lefts
                      .02,  .02,  .02, .02; ... % bottoms
                      repmat(.24, 1, 4); ... % widths
                      repmat(.24, 1, 4)]; % heights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD TRAIN & CONTROL ST BMS FILES, ASSIGN POSTERIORS TO VARIABLES
sidak_intervals = [.64, 99.36];
trn_bms_fname = [dat_fol st_fol 'train/' 'BMS.mat'];
[~, ~, ~, st_trn_b, st_trn_b_mus, ~, st_trn_b_prctiles] = get_grpLevel_params_by_grp_v2(trn_bms_fname,2,sidak_intervals);
ctrl_bms_fname = [dat_fol st_fol 'control/' 'BMS.mat'];
[~, ~, ~, st_ctrl_b, st_ctrl_b_mus, ~, st_ctrl_b_prctiles] = get_grpLevel_params_by_grp_v2(ctrl_bms_fname,2,sidak_intervals);

% PLOT AND SAVE
% settings for figure
idx   = [4, 6, 2, 7];     
% rows =[2, 1, 3, 1, 2];
% cols =[1, 2, 2, 3, 3];

x_range = [-.8, .8];
% figure;
% single colours
trn_sig_zero    = [1, 133, 113]; %[230, 97, 1];
trn_nsig_zero   = [128, 205, 193]; %[253, 184, 99];
ctrl_sig_zero   = [166, 97, 26]; %[94, 60, 153];
ctrl_nsig_zero  = [223, 194, 125];
line_col        = [211, 221, 220];
cols_for_st_fig = zeros(3, 3, length(idx));
cols_for_st_fig(:,:,1) = [trn_nsig_zero; ctrl_sig_zero; line_col];
cols_for_st_fig(:,:,2) = [trn_nsig_zero; ctrl_sig_zero; line_col];
cols_for_st_fig(:,:,3) = [trn_sig_zero; ctrl_nsig_zero; line_col];
cols_for_st_fig(:,:,4) = [trn_nsig_zero; ctrl_nsig_zero; line_col];
sig_group = [1, 1, 1, 0];

plot_grp_level_by_grp(idx, single_trials_pos, st_trn_b, st_trn_b_mus, st_trn_b_prctiles, st_ctrl_b, st_ctrl_b_mus, st_ctrl_b_prctiles, x_range, cols_for_st_fig, face_alpha, sig_group)

% save individual plot
% saveas(gcf, 'singTrialsPracPosts.eps');
% saveas(gcf, 'singTrialsPracPosts.bmp');
% 
% set(gcf,'Units','inches');
% screenposition = get(gcf,'Position');
% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
% print -dpdf -painters singTrialsPracPosts

hold off
clear BMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LOAD TRAIN & CONTROL MT BMS FILES, ASSIGN POSTERIORS TO VARIABLES
trn_bms_fname = [dat_fol mt_fol 'train/' 'BMS.mat'];
[~, ~, ~, mt_trn_b, mt_trn_b_mus, mt_trn_b_sds, mt_trn_b_prctiles] = get_grpLevel_params_by_grp_v2(trn_bms_fname,2,sidak_intervals);
ctrl_bms_fname = [dat_fol mt_fol 'control/' 'BMS.mat'];
[~, ~, ~, mt_ctrl_b, mt_ctrl_b_mus, mt_ctrl_b_sds, mt_ctrl_b_prctiles] = get_grpLevel_params_by_grp_v2(ctrl_bms_fname,2,sidak_intervals);

cols_for_mt_fig = zeros(3, 3, length(idx));
cols_for_mt_fig(:,:,1) = [trn_nsig_zero; ctrl_nsig_zero; line_col];
cols_for_mt_fig(:,:,2) = [trn_sig_zero; ctrl_sig_zero; line_col];
cols_for_mt_fig(:,:,3) = [trn_nsig_zero; ctrl_nsig_zero; line_col];
cols_for_mt_fig(:,:,4) = [trn_nsig_zero; ctrl_nsig_zero; line_col];
sig_group = [0, 1, 0, 0];
plot_grp_level_by_grp(idx, multi_trials_pos, mt_trn_b, mt_trn_b_mus, mt_trn_b_prctiles, mt_ctrl_b, mt_ctrl_b_mus, mt_ctrl_b_prctiles, x_range, cols_for_mt_fig, face_alpha, sig_group)

% % PLOT AND SAVE
% % settings for figure
% idx  = [2, 4, 6, 7, 8];      
% 
% x_range = [-.8, .8];
% trn_cols = [253, 184, 99;...
%             230, 97, 1; ...
%             211, 221, 220]; % line colour
% face_alpha = 1;
% 
% plot_grp_level_by_grp(idx, post_params_trn_pos, st_trn_b, st_trn_b_mus, st_trn_b_prctiles, mt_trn_b, mt_trn_b_mus,  mt_trn_b_prctiles, x_range, trn_cols, face_alpha);
% ctrl_cols = [178, 171, 210; ...
%              94, 60, 153;...
%              211, 221, 220]; % line colour
% plot_grp_level_by_grp(idx, post_params_ctrl_pos, st_ctrl_b, st_ctrl_b_mus, st_ctrl_b_prctiles, mt_ctrl_b, mt_ctrl_b_mus,  post_ctrl_b_prctiles, x_range, ctrl_cols, face_alpha);
% 
% 
% hold off
% clear BMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW WINNING MODELS

% settings for base model
cols       = [178,31,0; ...
              255,165, 37; ...
              0, 81, 161]';
cols       = cols/255;
node_names = {'IPS', 'Put', 'SMA'};
% 
% % PRCTICE SINGLE TASK TRIALS 
con_mat    = zeros(3,3);
con_mat(2) = 1;
con_mat([3, 8]) = 9;
input_node = 2;
font_size = 8;
% 
% TRAIN MODULATIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% single task
subplot('position', model_depict_locs(:,1)');
plot_single_model(cols, node_names, con_mat, input_node, font_size);
% 
% TRAIN MULTITASK TRIALS
con_mat    = zeros(3,3);
con_mat(6) = 1;
con_mat([3, 8]) = 9;
input_node = 2;
font_size = 8;
subplot('position', model_depict_locs(:,2)');
plot_single_model(cols, node_names, con_mat, input_node, font_size);
% 
% 
 % CONTROL %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% single-task
con_mat    = zeros(3,3);
con_mat([4, 6]) = 1;
con_mat([3, 8]) = 9;
input_node = 2;
font_size = 8;
subplot('position', model_depict_locs(:,3)');
plot_single_model(cols, node_names, con_mat, input_node, font_size);

% multitask
con_mat    = zeros(3,3);
con_mat(6) = 1;
con_mat([3, 8]) = 9;
input_node = 2;
font_size = 8;
subplot('position', model_depict_locs(:,4)');
plot_single_model(cols, node_names, con_mat, input_node, font_size);



% subplot('position', [.76, .2, .2, .2]);
% plot_single_model(cols, node_names, con_mat, input_node, font_size);
% 
% % TRAIN MULTITASK
% con_mat    = zeros(3,3);
% con_mat(8) = 1;
% con_mat(3) = 9;
% input_node = 2;
% font_size = 10;
% subplot('position', [.26, .2, .2, .2]);
% plot_single_model(cols, node_names, con_mat, input_node, font_size);

set(gcf,'Units','centimeters');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)*.8],...
    'PaperSize',[screenposition(3:4)*.8]);

% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
print -dpdf -painters 'prcFig'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW BASE MODELS

% settings for base model
cols       = [178,31,0; ...
              255,165, 37; ...
              0, 81, 161]';
cols       = cols/255;
node_names = {'IP', 'P', 'S'};

% SINGLE TASK TRIALS 
con_mat    = zeros(3,3);
%con_mat(6) = 1;
con_mat(3) = 9;
input_node = 2;
font_size = 8;
%subplot('position', [.81, .6, .19, .19]);
plot_single_model(cols, node_names, con_mat, input_node, font_size, 0.1, 0.2);

set(gcf,'Units','centimeters');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)*.2],...
    'PaperSize',[screenposition(3:4)*.2]);
print -dpdf -painters 'bseTrainFig'







