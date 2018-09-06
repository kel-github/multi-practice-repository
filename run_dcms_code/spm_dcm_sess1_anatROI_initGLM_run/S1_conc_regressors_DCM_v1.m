function S1_conc_regressors_v1(sub,n_s1_runs,s1_runs,fpath)
%%%%%%%%% function concatantes regressors assuming that this function is
%%%%%%%%% run from a folder where each participants output data is stored in the
%%%%%%%%% structure 'sub_[sub]_out/DCM_GLM/' with a txt file name beginning 'rp_af'
%%%%%%%%% v4 has removed the manual addition of regressors that were added
%%%%%%%%% by v3
%%%%%%%%% v1 is adopted from v4 of conc_regressors_SESS_v4.m
dat = [];
for x = 1:n_s1_runs
    dir_of_int = sprintf([fpath '/sub_%d%d/RUN%d/'],sub,1,s1_runs(x));
    fname = dir([dir_of_int 'rp_af*.txt']);
    %%%%%%% open file and read in data
    fid = fopen([dir_of_int fname.name],'rt');
    tmp = fscanf(fid,'%f %f %f %f %f %f',[6 inf])';
    dat = [dat; tmp];
    fclose(fid);
end
     
    %%%%%% save all regressors to a txt file
    all_regress = dat;
    
    save_dir = sprintf([fpath '/sub_%d_out_anatROI_initGLM/DCM_GLM/'],sub);
    fname = sprintf('%d_moveRegress_allScansSESS1.txt',sub);
    fname = [save_dir fname];
    fid = fopen(fname,'w');

    fprintf(fid,'%f %f %f %f %f %f\n', all_regress');

    fclose(fid);
end