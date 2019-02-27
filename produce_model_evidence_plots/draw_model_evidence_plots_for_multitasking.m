%%%% written by K. Garner, Oct 2018
%%%% code loads appropriate BMS files (s1 multitasking)  
%%%% and plots family evidence posteriors as overlapping
%%%% histograms
%%%% run this code from the folder that you want to save the figs in, and
%%%% the same folder that contains the plotting function
%%%% draws a figure that in final form is 11.6 x 15 cm (a 1.5 column fig
%%%% for somewhere like eNeuro).

%%%% STEPS
%%%% 1. set file structure/locations of data and define saving folder as
%%%% current
%%%% 2. set colours for family level inference
%%%% 3. load Session 1 INPUT Family BMS file, and pull out family
%%%% posteriors (p(f|m)), plot using defined histogram function,
%%%% save pdf, eps and bmp formats
%%%% 4. do same with Session 1 - connectivity pattern
%%%% 5. plot posteriors over connections (b and then a, save both in the
%%%% above formats)
%%%% 6. plot final model - save


%%%% subplot options (notes)
%     subplot(m,n,P), where P is a vector, specifies an axes position
%     that covers all the subplot positions listed in P.
%     subplot(H), where H is an axes handle, is another way of making
%     an axes current for subsequent plotting commands.
%  
%     subplot('position',[left bottom width height]) creates an
%     axes at the specified position in normalized coordinates (in
%     in the range from 0.0 to 1.0).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
% LOCATIONS
PLACE = 'qubes';

switch PLACE
    case 'home'
        
        addpath('~/Documents/MATLAB/spm12');
        dat_fol  = '~/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = pwd;
    case 'qubes'
        
        addpath('/home/kgarner/Documents/MATLAB/spm12');
        dat_fol  = '/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1_multitask_network_dcm_analysis_outdata'; % location of outputs for this analysis
        fig_fol  = pwd;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SESSION 1 SETTINGS
% http://colorbrewer2.org/?type=diverging&scheme=RdBu&n=6#type=qualitative&scheme=Dark2&n=5
% FAM 1: 178,24,43,0.4
% FAM 2: 239,138,98,0.4
% FAM 3: 253,219,199, 0.4
% POSTS = 103,169,207,0.4 | 33,102,172,0.4
cols    = [178,24,43; ...
           239,138,98; ...
           253,219,199];
face_alpha = 0.6;  
font_size = 8;
% %%%% SUBPLOT SETTINGS FOR MULTITASKING
% make_it_tight = true;
% subplot = @(m,n,p) subtightplot (m, n, p, [0.1 0.1], [0.01 0.01], [0.04 0.02]);
% if ~make_it_tight,  clear subplot;  end


%%%%%% trying the subplot 'position' function % left, bottom, width, height
inp_fam_pos = [0.08, 0.62, 0.4, 0.3];
con_fam_pos = [0.57, 0.62, 0.4, 0.3];
post_params_sub_pos = [[.08, .25, .42, .08, .25, .42];... % lefts
                       [.36, .36, .36, .12, .12, .12];... % bottoms
                       repmat(.14, 1, 6);... %widths
                       repmat(.12, 1, 6)]; % heights
win_mod_pos = [.64, .04, .35, .35];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT FAMILY BMS
load([dat_fol '/input_family_comparison/BMS.mat']);
fam_posts = BMS.DCM.rfx.family.s_samp;
exc_probs = BMS.DCM.rfx.family.xp;

%%%% start plot
figure;
y_on = 1;
%subtightplot(p_rows,p_cols,1, [0.1 0.1], [0.01 0.01], [0.08 0.02]) 
subplot('position', inp_fam_pos);
leg_loc = 'southoutside';
annot_loc = [.23, .95, .5, .05]; % annotation location
plot_family_posteriors(fam_posts, cols, face_alpha, 0, exc_probs, y_on, leg_loc, 'horizontal', font_size, annot_loc);

% set(gcf,'Units','inches');
% screenposition = get(gcf,'Position');
% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
% print -dpdf -painters multFamInp
% 
% hold off
clear BMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORTICAL FAMILY BMS
load([dat_fol '/connection_family_comparison/BMS.mat']);
fam_posts = BMS.DCM.rfx.family.s_samp;
exc_probs = BMS.DCM.rfx.family.xp;
y_on = 0;
annot_loc = [.725, .95, .5, .05];
subplot('position', con_fam_pos);
leg_loc = 'southoutside';
plot_family_posteriors(fam_posts, cols, face_alpha, 0, exc_probs, y_on, leg_loc, 'vertical', font_size, annot_loc);

% % save individual plot
% saveas(gcf, 'multFamCon.eps');
% saveas(gcf, 'multFamCon.bmp');
% 
% set(gcf,'Units','inches');
% screenposition = get(gcf,'Position');
% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
% print -dpdf -painters multFamCon
% 
% hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CORTICAL FAMILY BMA
bs = squeeze(BMS.DCM.rfx.bma.b(:,:,2,:));
B_mus = BMS.DCM.rfx.bma.mEp.B(:,:,2);
B_prctiles  = prctile(bs, [.4, 99.6], 3); % adjusted for comparisons

%%%%%% code to plot histograms for each connection, with mu and CIs as 
%%%%%% dotted lines

%%% some standard things
x_range = [-.25, .5];
idx = [4, 2, 7, 6, 3, 8];   % to index the row/column matrices in the plot_grp_level_params function
%p_rows =[2, 3, 1, 3, 1, 2];
%p_cols =[1, 1, 2, 2, 3, 3];
face_col = [ 103,169,207];
colours = [face_col; 112,128,144];
%figure;
plot_grp_level_params(bs, idx, colours, post_params_sub_pos, B_mus, B_prctiles, x_range);

% % save individual plot
% saveas(gcf, 'multFamConPosts.eps');
% saveas(gcf, 'multFamConPosts.bmp');
% 
% set(gcf,'Units','inches');
% screenposition = get(gcf,'Position');
% set(gcf,...
%     'PaperPosition',[0 0 screenposition(3:4)],...
%     'PaperSize',[screenposition(3:4)]);
% print -dpdf -painters multFamConPosts

hold off
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DRAW WINNING MODEL
% settings for base model
cols       = [178,31,0; ...
              255,165, 37; ...
              0, 81, 161]';
cols       = cols/255;
node_names = {'IPS', 'Put', 'SMA'};
con_mat    = zeros(3,3);

con_mat([4]) = 1;
con_mat([3 8]) = 9;
input_node = 2;
font_size = 10;
subplot('position', win_mod_pos);
plot_single_model(cols, node_names, con_mat, input_node, font_size);

% saveas(gcf, 'multWin.eps');
% saveas(gcf, 'multWin.bmp');

set(gcf,'Units','centimeters');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3)*4 screenposition(4)*4],...
    'PaperSize',[screenposition(3)*4 screenposition(4)*4]);
print -dpdf -painters multFig_Poster
set(gcf,...
    'PaperPosition',[0 0 screenposition(3)*.8 screenposition(4)*.8],...
    'PaperSize',[screenposition(3)*.8 screenposition(4)*.8]);
print -dpdf -painters multFig

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTENDED FIG - A PARAMS
bs = squeeze(BMS.DCM.rfx.bma.a(:,:,:));
B_mus = BMS.DCM.rfx.bma.mEp.A;
B_prctiles  = prctile(bs, [2.5, 97.5], 3);
x_range = 9;
figure;
plot_grp_level_params(bs, idx, colours, post_params_sub_pos, B_mus, B_prctiles, x_range);

set(gcf,'Units','centimeters');
screenposition = get(gcf,'Position');
set(gcf,...
    'PaperPosition',[0 0 screenposition(3:4)*.8],...
    'PaperSize',[screenposition(3:4)*.8]);
print -dpdf -painters multFamConPostsA
clear BMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

