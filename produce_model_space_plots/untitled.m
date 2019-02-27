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
node_names = {'IP', 'P', 'S'};
con_mat    = zeros(3,3);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input family
plot_rows  = 1;
plot_cols  = 2;
input_node = 1;
subplot(plot_rows, plot_cols, 1)
plot_single_model(cols, node_names, con_mat, input_node);
txt = 'i) Families defined by input node';
font_size = 12;
text(5, 14, txt, 'HorizontalAlignment', 'center', 'FontSize', font_size);
subplot(plot_rows, plot_cols, 2)
input_node = 2;
plot_single_model(cols, node_names, con_mat, input_node);

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% modulatory family
figure;
plot_rows  = 1;
plot_cols  = 3;
input_node = 2;
subplot(plot_rows, plot_cols, 1)
con_mat = zeros(3,3);
con_mat([2, 4, 6, 8]) = 1;
plot_single_model(cols, node_names, con_mat, input_node);
txt = 'ii) Families defined by cortical/striatal connectivity';
font_size = 12;
text(20, 15, txt, 'HorizontalAlignment', 'center', 'FontSize', font_size);
% draw red lines to indicate unallowed connectivity modulations
line([5 7], [8.5 13.5], 'Color', 'red', 'LineWidth', 2);
line([5 7], [13.5 8.5], 'Color', 'red', 'LineWidth', 2);

subplot(plot_rows, plot_cols, 2)
con_mat = zeros(3,3);
con_mat([3, 7]) = 1;
plot_single_model(cols, node_names, con_mat, input_node);
% draw red lines to indicate unallowed connectivity modulations
line([-2 4], [3 7], 'Color', 'red', 'LineWidth', 2);
line([4 -2], [3 7], 'Color', 'red', 'LineWidth', 2);