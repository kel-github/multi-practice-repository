%% get data to run FC between brain regions, for Garner et al, 2020, https://doi.org/10.1101/564450
% written by K. Garner, 2020

%% This code will take time courses for each ROI defined, split and concatenate by condition 
% and calculate the FC between brain regions, as requested by the editor at
% eNeuro
clear all

%%  first define the subject and path variables - SET ALL THESE VARIABLES PRIOR TO RUNNING CODE
cdir = pwd;
data_dir = '/Volumes/HouseShare/';
dat_fol = 'RH_s2_MULTTRIALS_MODELS_OUT.zip';
save_dir = '~/Dropbox/QBI/mult-conn/multi-practice-repository/processed-data/';
save_fname = 's2_RH_MULT_tSERIES';

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

sub_cond_a_data = []; % for collecting the timecourse data
sub_cond_b_data = []; 
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

for i = fidx 
       
    unzip(fnames{i})
    if any(s2_RH_Mult)
        cd(fnames{i}(1:(end-4)));
    else
       cd(fnames{i}(length(dat_fol(1:end-3))+1:(end-4)));  
    end
    
    vois = dir('FSTL_GLM/*_1.mat');
    glm = 'DCM_GLM/SPM.mat';
    
    if length(vois) < 3
    else
        get_sub_idx = regexp(fnames{i}, 'sub_[0-9]');
        sub = str2num(fnames{i}(get_sub_idx+4:get_sub_idx+6));
        % first load glm and get the onsets for each condition, to be taken
        % from the time series
        glmstuff = load(glm);
        cond_a = glmstuff.SPM.xX.X(:,2) == 0;
        cond_b = glmstuff.SPM.xX.X(:,2) > 0;
        
        % now load the timeseries for each roi and get the datapoints for each
        % condition
        % now upload timecourse data from each identified voi file
        for iR = 1:nregions
            dat = load(['FSTL_GLM/' vois(iR).name], 'Y');
            if iR == 1
                cond_a_data =  dat.Y(cond_a);
                cond_b_data = dat.Y(cond_b);
            else
                cond_a_data(:,iR) = dat.Y(cond_a);
                cond_b_data(:,iR) = dat.Y(cond_b);
            end
        end
    end
    cond_a_data(:,4) = sub;
    cond_b_data(:,4) = sub;
    
    sub_cond_a_data = [sub_cond_a_data; cond_a_data]; 
    sub_cond_b_data = [sub_cond_b_data; cond_b_data];
    cd(cdir);
    if any(s2_RH_Mult)
        rmdir(sprintf(fnames{i}(1:(end-4))), 's');
    else
        rmdir(sprintf(fnames{i}(length(dat_fol(1:end-3))+1:(end-4))), 's');
    end
end

sub_cond_a_data(:,5) = 1;
sub_cond_b_data(:,5) = 2;
all_data = [sub_cond_a_data; sub_cond_b_data];

% remove the unarchived files
rmdir('*OUT', 's');
delete('*_anatROI_*');

%% save the data
save([save_dir, save_fname], 'all_data');
writematrix(all_data, [save_dir, save_fname '.csv']);
csvwrite([save_dir, save_fname '.csv'], all_data);
