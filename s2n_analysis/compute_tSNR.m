%% comparing tSNRs between brain regions, for Garner et al, 2020, https://doi.org/10.1101/564450
% written by K. Garner, 2020
%% This code will take time courses for each ROI defined and calculate the std as a measure of 
% signal noise (e.g. Forstmann, 2017)
%

clear all
%%  first define the subject and path variables - SET ALL THESE VARIABLES PRIOR TO RUNNING CODE
cdir = pwd;
data_dir = '/Volumes/HouseShare/';
dat_fol = 'RH_s2_MULTTRIALS_MODELS_OUT.zip';
save_dir = '~/Dropbox/QBI/mult-conn/multi-practice-repository/processed-data/';
save_fname = 's2_RH_MULT';
% details about the DCM
nregions = 3;
s1_LH = 0;
s1_RH = 0; % if running ses 1, RH, remove unrequired hidden filenames from fnames variable below
s2_LH_Sing = 0;
s2_RH_Sing = 0;
s2_LH_mult = 0;
s2_RH_Mult = 1;

%% extract the data
% unzip the archive to the current directory
fnames = unzip(sprintf([data_dir, dat_fol])); % unzip the archive to the current folder

tSTD = []; % for collecting the timecourse data

if any(s1_LH|s2_LH_Sing)   
   fidx = 2:2:length(fnames);
end

if any(s2_RH_Sing)
   fidx = [2:101]; 
end

if any(s1_RH) 
   fnames(1) = [];
   fnames(14:17) = []; 
   fidx = 1:length(fnames);
end

if any(s2_LH_mult)
   fidx = 3:2:201; 
end

if any(s2_RH_Mult)
    fidx = 2:100;
end


for i = fidx % its 2:2 because I accidentally printed empty folders when archiving this data

    this_p_std = [];
    unzip(fnames{i})
    if any(s2_RH_Mult)
        cd(fnames{i}(1:(end-4)));
    else
       cd(fnames{i}(length(dat_fol(1:end-3))+1:(end-4)));  
    end

    vois = dir('FSTL_GLM/*_1.mat');
    if length(vois) < 3
    else
        % now upload timecourse data from each identified voi file
        for iR = 1:nregions
            dat = load(['FSTL_GLM/' vois(iR).name], 'Y');
            tc_sdev = nanstd(dat.Y);
            this_p_std = [this_p_std, tc_sdev];
        end
        tSTD = [tSTD; this_p_std];
        
    end
    cd(cdir);
    if any(s2_RH_Mult)
        rmdir(sprintf(fnames{i}(1:(end-4))), 's');
    else
        rmdir(sprintf(fnames{i}(length(dat_fol(1:end-3))+1:(end-4))), 's');
    end
end

% remove the unarchived files
rmdir('*OUT', 's');
delete('*_anatROI_*');


%% save the data
save([save_dir, save_fname], 'tSTD');
writematrix(tSTD, [save_dir, save_fname '.csv']);
csvwrite([save_dir, save_fname '.csv'], tSTD);
% 
