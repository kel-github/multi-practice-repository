%
% colour blind friendly palette 
% https://color.adobe.com/Colorblind-Safe-color-theme-8226405/
% using colours 1, 3, & 5
% #B21F00 - 178,31,0
% #FFA525 - 255, 165, 37
% #0051A1 - 0, 81, 161

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% K. Garner, 2018
% code plots figure that depicts the questions tested regarding the
% modulatory influence of multitasking on this network

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot panels
% n x m subplot matrix
% panels 2:3 = base model
% panels 6:8 = input families
% panels 10:12 = connection families
figure;
% settings for base model
cols       = [178,31,0; ...
              255,165, 37; ...
              0, 81, 161]';
cols       = cols/255;
node_names = {'IPS', 'Put', 'SMA'};
con_mat    = zeros(3,3);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input family
plot_rows  = 1;
plot_cols  = 2;
input_node = 1;
subplot(plot_rows, plot_cols, 1)
plot_single_model(cols, node_names, con_mat, input_node, 10);
%txt = 'i) Families defined by input node';
% font_size = 12;
% text(5, 14, txt, 'HorizontalAlignment', 'center', 'FontSize', font_size);

subplot(plot_rows, plot_cols, 2)
input_node = 2;
plot_single_model(cols, node_names, con_mat, input_node, 10);
print('input_family', '-dpng');
print('input_family', '-dpdf');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modulatory family
figure;
plot_rows  = 1;
plot_cols  = 3;
input_node = 2;
subplot(plot_rows, plot_cols, 1)
con_mat = zeros(3,3);
con_mat([2, 4, 6, 8]) = 1;
plot_single_model(cols, node_names, con_mat, input_node, 8);
% txt = 'ii) Families defined by cortical/striatal connectivity';
% font_size = 12;
% text(20, 15, txt, 'HorizontalAlignment', 'center', 'FontSize', font_size);

subplot(plot_rows, plot_cols, 2)
con_mat = zeros(3,3);
con_mat([3, 7]) = 1;
plot_single_model(cols, node_names, con_mat, input_node, 8);

subplot(plot_rows, plot_cols, 3);
con_mat = ones(3,3);
plot_single_model(cols, node_names, con_mat, input_node, 8);
print('connect_pattern_family', '-dpng');
print('connect_pattern_family', '-dpdf');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model space (for extended figure)
figure;
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.01 0.01], [0.01 0.01]);
if ~make_it_tight,  clear subplot;  end

con_mats = load('b_mats_v3.mat');
plot_rows = 8;
plot_cols = 8;
pos_xs = linspace(0,1,9);
pos_xs = repmat(pos_xs(1:8), 1, 8);
pos_ys = [];
for i = 1:8
    pos_ys = [pos_ys repmat(pos_xs(i), 1, 8)];
end
for i = 1:size(con_mats.b_mats,3)
    con_mat = con_mats.b_mats(:,:,i);
    subplot(plot_rows, plot_cols, i);
    plot_single_model(cols, node_names, con_mat, 3, 0);
%     pos = get(gca, 'Position');
%     pos(1) = pos_xs(i);
%     pos(2) = pos_ys(i);
%     set(gca, 'Position', pos)
end
txt = 'Model space for modulatory influence of multitasking';
font_size = 12;
text(-118.2088  ,  182.5054, txt, 'HorizontalAlignment', 'left', 'FontSize', font_size);
print('multitask_model_space', '-dpng');
print('multitask_model_space', '-dpdf');

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% model space for practice, for extended figure
figure;
make_it_tight = true;
subplot = @(m,n,p) subtightplot (m, n, p, [0.01 0.05], [0.01 0.01], [0.01 0.01]);
if ~make_it_tight,  clear subplot;  end

con_mats = load('b_mats_v5.mat');
con_mats.b_mats(3,1,:) = 9;
con_mats.b_mats(2,3,:) = 9;
plot_rows = 3;
plot_cols = 5;

for i = 1:size(con_mats.b_mats,3)
    con_mat = con_mats.b_mats(:,:,i);
    subplot(plot_rows, plot_cols, i);
    plot_single_model(cols, node_names, con_mat, 3, 0);
%     pos = get(gca, 'Position');
%     pos(1) = pos_xs(i);
%     pos(2) = pos_ys(i);
%     set(gca, 'Position', pos)
end
%txt = 'Model space for modulatory influence of practice';
%font_size = 10;
%text(-80.8402,  87.9524, txt, 'HorizontalAlignment', 'left', 'FontSize', font_size);

print('practice_model_space', '-dpng');
print('practice_model_space', '-dpdf');