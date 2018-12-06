function [peak_data] = get_participant_peaks(sub_nums, fpath, fname)

% written by K. Garner, 2018
% this function will extract the coordinates of the peak activity
% within the pre-defined anatomical regions of interest (LIPL, LPut, and
% SMFC). Returns a nsubs x xyz x nregions matrix.
% sub_nums = a vector of subject numbers for which data is to be extracted
% fpath    = the file path to the directory that contains all the subject
% folders
% fname    = the template name for the subject folder, with %d substituted for the number
n_regions = 3;
peak_data = zeros(length(sub_nums), 3, n_regions);

% get current directory
cdir = [pwd '/'];
for i = 1:length(sub_nums)
    
   cd(sprintf([fpath  '/' fname '/FSTL_GLM'], sub_nums(i)));
   load('VOI_LIPL_1.mat','xY');
   peak_data(i, :, 1) = xY.xyz;
   clear xY
   load('VOI_LPut_1.mat','xY');
   peak_data(i, :, 2) = xY.xyz;   
   clear xY
   load('VOI_SMFC_1.mat','xY');
   peak_data(i, :, 3) = xY.xyz;   
   clear xY     
end

cd(cdir);
end