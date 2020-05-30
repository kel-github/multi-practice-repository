function run_dcm_checks(sub_nums, sub_fol, data_dir, model_nums, model_stem)
% this code generates the variable of filenames/paths to DCM models and
% then plugs into the spm function for fmri dcm model checking
% written by K. Garner, May 2018
% inputs:
% sub_nums = vector of the subject numbers required for checking
% data_dir = path to folder containing subject output folders
% model_nums = vector of the number/idxs of the b_mats/mode numbers
% model_stem = cell input - if models have a different driving input, then
% that shows up in the naming of the DCM .mat file

% output is the figure showing outcomes of the model checks
% generate variable of model file names
mfnames = cell(length(sub_nums), length(model_nums)*length(model_stem), 1);


for count_subs = 1:length(sub_nums) % across subs
 
        count_mods = 0;   
    for count_model_typs = 1:length(model_stem) % for each input/model type
        
        for count_ms = 1:length(model_nums) % specific b_mat number
            
            count_mods = count_mods + 1;
            mfnames{count_subs, count_mods} = fullfile(data_dir, sprintf(sub_fol, sub_nums(count_subs)), ...
                                                       'DCM_OUT', sprintf(model_stem{count_model_typs}, model_nums(count_ms)));
        end
    end
end

spm_dcm_fmri_check(mfnames);
