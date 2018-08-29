function var = get_total_variance(sub_nums, model_stems, n_mods, data_dir, sub_fol)
% written by K. Garner, 2018
% this code will load the DCM output files defined by sub numbers, model
% names, n_mods (total number of models in subject folder) within the
% directories jointly specified  by data_dir and sub_fol
% code then adds the predicted and observed timeseries values to a vector 
% and then computes coefficient of determination across all subjects and
% models
RSS = [];
PSS = [];
% enter [] for var to accumulate from scratch
for count_subs = 1:length(sub_nums)
    
    sub = sub_nums(count_subs);
    
    for count_stems = 1:length(model_stems)
        
        for count_mods = 1:n_mods
    
            fname = fullfile(data_dir,sprintf(sub_fol, sub), sprintf(model_stems{count_stems}, count_mods));
            load(fname, 'DCM');

            PSS = [PSS sum(sum(DCM.y.^2))];
            RSS = [RSS sum(sum(DCM.R.^2))];
            clear DCM
        end
    end


end

    var = sum(PSS)/(sum(PSS) + sum(RSS));
end