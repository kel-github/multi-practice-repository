function [subj] = get_model_space_filenames_v2(sub_nums, fnames, ms, base, mfname)
% DCM RESULTS - write model space file
% _________________________________________________________________________
% (c) K. Garner 6th Sept 2016

% writes model space file for multitasking fmri results -
% for all subjects (100) and all models (126)
% model space files contain name of model mat files, plus F, Ep and Cp for
% each model

% Dependencies 
% Matlab R2015a
% SPM12 v6685
% -------------------------------------------------------------------------

for s = 1:length(sub_nums)
    m_cnt = 0;
    for f = 1:length(fnames)
    for m = 1:ms
        m_cnt = m_cnt + 1;
        subj(s).sess(1).model(m_cnt).fname = ...
            fullfile(base,sprintf('sub_%d_out_anatROI_initGLM',sub_nums(s)),'DCM_OUT',sprintf(fnames{f},m));
        
        load(subj(s).sess(1).model(m_cnt).fname);
        subj(s).sess(1).model(m_cnt).F = F;
        subj(s).sess(1).model(m_cnt).Ep = Ep;
        subj(s).sess(1).model(m_cnt).Cp = Cp;
    end
    end
end

save(sprintf(mfname), 'subj');







