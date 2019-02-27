function [] = plot_single_model(cols, node_names, con_mat, input_node, font_size, solid_width, dotted_width)

% ---------------------------------------------------------

% DEPENDENCIES
% ________________________________________________________
% Matlab R2018a
% (c) K. Garner 2016
% proudces a 3 node figure, with any number of reciprocal connections
% input arguments:
 %   cols = a 3 x 3 matrix of colours for nodes and their associated
 %   connections (rows = rgb, cols = node)
 %   node_colour = [0 0 0];
 %   node_names = a 1 x 3 cell, each containing the letter to be printed on
 %   the node
 %   con_idx = 3 x 3 matrix, rows = too, cols = from - 1 = modulatory connection, 0
 %   = endogenous but not modulatory, 9 = no connection
 %   input node = 1 if LIPL, 2 if Putamen
 %   text_on = 1 for include node names, 0 = do not
 %   input_on = 1 for include input arrow, 0 = no arrow
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%% aesthetics %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n_nodes      = 3; 
if nargin < 7
    solid_width  = 2.5;
    dotted_width = 1.5;
else
end
if nargin < 5
    font_size    = 18;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% dimensions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
maj_r             = 6; % radius of outer circle for positioning;
min_r             = 4; % radius of inner circle for positioning
maj_circ_center_x = 6; % origin of major circle
maj_circ_center_y = 6; % 
node_origin       = 5; % radius where centres of nodes should be
node_r            = 1.5;
self_r            = 0.8;
self_offset       = 1;
node_width        = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% nodes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%% step 1 - get coordinates for node centers
thetas = [3*pi/4, pi/2, pi/4]; % for origin or circle
self_thetas = [5*pi/4, 3.2,   5.23; ...
               pi/5,   6.3, 8.55 ]; % for what to include of self connection circle
circ_center_x(1) = maj_circ_center_x + node_origin*cos(thetas(1));
circ_center_y(1) = maj_circ_center_y + node_origin*sin(thetas(1));
self_center_x(1) = maj_circ_center_x - self_offset + node_origin*cos(thetas(1));
self_center_y(1) = maj_circ_center_y + self_offset + node_origin*sin(thetas(1));

circ_center_x(2) = node_origin*cos(thetas(2)) + maj_circ_center_x;
circ_center_y(2) = maj_circ_center_y - node_origin*sin(thetas(2));
self_center_x(2) = node_origin*cos(thetas(2)) + maj_circ_center_x;
self_center_y(2) = maj_circ_center_y - (self_offset+0.5) - node_origin*sin(thetas(2));

circ_center_x(3) = node_origin*cos(thetas(3)) + maj_circ_center_x;
circ_center_y(3) = node_origin*sin(thetas(3)) + maj_circ_center_y;
self_center_x(3) = maj_circ_center_x + self_offset + node_origin*cos(thetas(3));
self_center_y(3) = maj_circ_center_y + self_offset + node_origin*sin(thetas(3));
%%%%%% step 2 - plot nodes with self connections
th = linspace(0, 2*pi, 100); % define circle in theta
for i = 1:n_nodes
    x = node_r*cos(th) + circ_center_x(i); % convert to x
    y = node_r*sin(th) + circ_center_y(i); % convert to y
    plot(x,y, 'Color', cols(:,i), 'LineWidth', node_width);
    if  i == 1
        hold on
    end
    if font_size > 0
        txt = node_names{i};
        text(circ_center_x(i), circ_center_y(i), txt, 'HorizontalAlignment', 'center', 'FontSize', font_size);
    end
    self_th = linspace(self_thetas(1,i), self_thetas(2,i), 100);
    self_x = self_r*cos(self_th) + self_center_x(i);
    self_y = self_r*sin(self_th) + self_center_y(i);
    plot(self_x, self_y, 'Color', [105 105 105]/255,  'LineStyle', ':', 'LineWidth', dotted_width);
end

%%%%%%%%%%%%%%%%%%%%%%% endogenous connections: on/off %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this will refer to the matrices passed in, in the final version
% bmat format
%           from
%           lipl lput smfc
%to lipl    1     4    7
%   lput    2     5    8
%   smfc    3     6    9

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% connections %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
points   = 100; % how many points in the line
con_idx  = [2, 3, 4, 6, 7, 8]; % idx to connections provided by con_idx
% con_cols = repmat(cols, 1, 2); % FOR COLOURS
con_cols = repmat([105, 105, 105]', 1, 3)/255; % for grey
con_cols = repmat(con_cols, 1, 2); % for grey
con_cols = con_cols(:, [1, 4, 2, 5, 3, 6]); % colours coded by region acting on the other (i.e. from/to)
thetas   = [5*pi/6,    2*pi/3, 5*pi/6,    3.5*pi/6, 2*pi/3, 3.5*pi/6; ... % draw lines to and from
            4.25*pi/3, pi/3,   4.25*pi/3, 3.5*pi/3, pi/3,   3.5*pi/3];
co_sign  = [1 1 1 -1 1 -1]; % flips the sign of the coordinates to negative if necessary
con_rs   = [ maj_r, maj_r, min_r, min_r, min_r, maj_r ]; % place connecting line on inner or outer circle

% now define the arrow heads for which region is acting on which
%%%%%%%  coords = [max_x, min_y;... 
%                  max_x, min_y;...
%                  max_x, min_y;...
%                  min_x, max_y;...
%                  min_x, max_y;...
%                  min_x, min_y];
%%% coordinates obtained using [x, y] = ginput(6);
x = zeros(6, 3);
y = zeros(6, 3);
x(1, :) = [4.1613, 4.4101, 3.8848];
y(1, :) = [1.1633, 0.2245, -0.3061];

x(2, :) = [8.2258, 8.9171,  9.0276];
y(2, :) = [10.9592, 11.2041, 11.8163];

x(3, :) = [1.8387, 2.4747, 2.7512];
y(3, :) = [7.5714, 7.9388, 7.1224];

x(4, :) = [9.1935, 9.4424, 10.1613];
y(4, :) = [7.1224, 7.9388, 7.8163];

x(5, :) = [4.5484, 4.0230, 4.3272];
y(5, :) = [8.8367, 9.5306, 10.4694];

x(6, :) = [8.1982, 7.5346, 7.8664];
y(6, :) = [-0.3878, 0.1837, 1.1633];            
dot_size   = 0.7; 

for i = 1:length(con_idx) 
   
    this_theta = linspace(thetas(1,i), thetas(2,i), points);
    xs         = (con_rs(i)*cos(this_theta) + (maj_circ_center_x*co_sign(i)))*co_sign(i);
    ys         = (con_rs(i)*sin(this_theta) + (maj_circ_center_y*co_sign(i)))*co_sign(i);
    this_con   = con_mat(con_idx(i));
    if this_con > 1 % don't draw
    elseif this_con == 1         
        plot(xs, ys, 'Color', con_cols(:, i), 'LineStyle', '-', 'LineWidth', solid_width);
        plot(x(i, [1 2]), y(i, [1 2]), 'Color', con_cols(:, i), 'LineStyle', '-', 'LineWidth', solid_width);
        plot(x(i, [2 3]), y(i, [2 3]), 'Color', con_cols(:, i), 'LineStyle', '-', 'LineWidth', solid_width);
    elseif ~any(this_con)
        plot(xs, ys, 'Color', con_cols(:, i), 'LineStyle', ':', 'LineWidth', dotted_width); 
        plot(x(i, [1 2]), y(i, [1 2]), 'Color', con_cols(:, i), 'LineStyle', ':', 'LineWidth', dotted_width); 
        plot(x(i, [2 3]), y(i, [2 3]), 'Color', con_cols(:, i), 'LineStyle', ':', 'LineWidth', dotted_width); 
    end   
end 

% now draw input 
if input_node == 1
    arrow_start = [4.6866    7.0000]; %[0.0772, 11.8277];
    arrow_end   = [3.7465    8.3061]; %[1.4007, 10.7991];
elseif input_node == 2
    arrow_start = [5.9585    4.0612];
    arrow_end   = [6.0138    2.8367];
end
if input_node ~= 3
    arrow(arrow_start, arrow_end, 'EdgeColor', [0 0 0]/255, 'FaceColor', [0 0 0]/255);
end

axis equal;
set(gca,'visible','off')
set(gca,'XtickLabel',[],'YtickLabel',[]);

end