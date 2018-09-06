% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/home/kgarner/Dropbox/QBI/mult-conn/multi-practice-repository/s1s2_mt_practice_dcm_analysis_code/batch1a_allsubs_BMA_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
