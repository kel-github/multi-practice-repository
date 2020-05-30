%% comparing subject regions to group-based ROI, for Garner et al, 2020, https://doi.org/10.1101/564450
% written by K. Garner, 2020

%% set group level variables
% 
% roiR = 4; % roi radius, in mm
% roiD = 8;
% voxel_size = 3; % cubed voxel size, 3 mm 
% 
% % define group level peaks in mni space, converted from Garner & Dux, 2015
% % using http://sprout022.sprout.yale.edu/mni2tal/mni2tal.html
% lipl = [-36, -55, 44];
% lput = [-25, 8, 1];
% smfc = [-8, -12, 61];
% ripl = [35, -41, 45];
% rput = [20, 11, 1];
% 
% % number of voxels in each direction
% % make a spherical mask in 3d
% base_roi = zeros(5, 5, 5);
% centre = [3, 3, 3];


%% for each subject, load in their individual ROI mask files, add to the given structure,
%% at the end create a proportion correct for each region of interest, and then make into
%% one image. Plot in 3 dimensional space.

clear all
%%  first define the subject and path variables - SET ALL THESE VARIABLES PRIOR TO RUNNING CODE
cdir = pwd;
data_dir = '/Volumes/HouseShare/';
dat_fol = 's2_SINGTRIALS_MODELS_OUT.zip';
save_dir = '~/Dropbox/QBI/mult-conn/multi-practice-repository/processed-data/';
save_fname = 's2_LH_SING_ROIs';
% details about the DCM
nregions = 3;
s1_LH = 0;
s1_RH = 0; % if running ses 1, RH, remove unrequired hidden filenames from fnames variable below
s2_LH_Sing = 1;
s2_RH_Sing = 0;
s2_LH_mult = 0;
s2_RH_Mult = 0;

%% extract the LH data
% unzip the archive to the current directory
fnames = unzip(sprintf([data_dir, dat_fol])); % unzip the archive to the current folder

if any(s1_LH|s2_LH_Sing)   
   fidx = 2:2:length(fnames);
end

if any(s1_RH) 
   fnames(1) = [];
   fnames(14:17) = []; 
   fidx = 1:length(fnames);
end

if any(s2_RH_Sing)
   fidx = [2:101]; 
end

if any(s2_LH_mult)
   fidx = 3:2:201; 
end

% variable for collecting the mask file data
M = zeros(53, 63, 52, 'uint8');

for i = fidx    
    % get the subjects mask filenames
    unzip(fnames{i})
    cd(fnames{i}(length(dat_fol(1:end-3))+1:(end-4)));
    masks = dir('FSTL_GLM/*_mask.nii');
    
    % now open each mask file and add to the previous
    for iMask = 1:length(masks)
        if iMask == 1 && i == min(fidx)
            info = niftiinfo(['FSTL_GLM/' masks(iMask).name]);
        end
        V = niftiread(['FSTL_GLM/' masks(iMask).name]);
        M = M + V;
        clear V
    end
    cd(cdir);
    rmdir(sprintf(fnames{i}(length(dat_fol(1:end-3))+1:(end-4))), 's');
end

% remove the unarchived files
rmdir('*OUT', 's');

%% compute percentages and save data
M = double(M);
M = M./length(fidx);
%M = uint8(M);
info.Datatype = 'double';
niftiwrite(M, [save_dir, save_fname, '.nii'],info);



