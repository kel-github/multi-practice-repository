% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/Users/kels/Dropbox/QBI/mult-conn/multi-practice-repository/RH_s1s2_RHwin_singOut_practice_dcm_analysis_code/batch2_train_BMA_job_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
