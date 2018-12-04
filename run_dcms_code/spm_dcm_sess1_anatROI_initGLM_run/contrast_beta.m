% List of open inputs
nrun = X; % enter the number of runs here
jobfile = {'/home/kgarner/mult-conn/repos/multi-task-train-conn-change/DCM_code_cluster/spm_dcm_sess1/contrast_beta_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(0, nrun);
for crun = 1:nrun
end
spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
