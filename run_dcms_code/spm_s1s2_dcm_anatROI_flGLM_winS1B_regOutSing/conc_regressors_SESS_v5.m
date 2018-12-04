function conc_regressors_SESS_v5(sub,n_s1_runs,n_s2_runs,s1_runs,s2_runs,fpath, sfol)
%%%%%%%%% function concatantes regressors assuming that this function is
%%%%%%%%% run from a folder where each participants output data is stored in the
%%%%%%%%% structure 'sub_[sub]_out/DCM_GLM/' with a txt file name beginning 'rp_af'
%%%%%%%%% v4 has removed the manual addition of regressors that were added
%%%%%%%%% by v3
%%%%%%%%% v5 allows specification of a unique subject folder name for
%%%%%%%%% output
dat = [];
for x = 1:n_s1_runs
    dir_of_int = sprintf([fpath '/sub_%d%d_out/RUN%d/'],sub,1,s1_runs(x));
    fname = dir([dir_of_int 'rp_af*.txt']);
    %%%%%%% open file and read in data
    fid = fopen([dir_of_int fname.name],'rt');
    tmp = fscanf(fid,'%f %f %f %f %f %f',[6 inf])';
    dat = [dat; tmp];
    fclose(fid);
end

for x = 1:n_s2_runs
    dir_of_int = sprintf([fpath '/sub_%d%d_out/RUN%d/'],sub,2,s2_runs(x));
    fname = dir([dir_of_int 'rp_af*.txt']);
    %%%%%%% open file and read in data
    fid = fopen([dir_of_int fname.name],'rt');
    tmp = fscanf(fid,'%f %f %f %f %f %f',[6 inf])';
    dat = [dat; tmp];
    fclose(fid);
end    
   
    %%%%%% save all regressors to a txt file
    all_regress = dat;
    save_dir = {sprintf([fpath '/' sfol '/FSTL_GLM/'],sub), sprintf([fpath '/' sfol '/DCM_GLM/'],sub)};
    
    for count_saves = 1:length(save_dir)
        fname = sprintf('%d_moveRegress_allScansBOTHSESS.txt',sub);
        fname = [save_dir{count_saves} fname];
        fid = fopen(fname,'w');       
        fprintf(fid,'%f %f %f %f %f %f\n', all_regress');      
        fclose(fid);
    end   
end