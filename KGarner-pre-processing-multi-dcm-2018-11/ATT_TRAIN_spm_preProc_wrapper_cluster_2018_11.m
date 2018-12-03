% written by K. Garner, 2018
% SPM pre-processing code for fMRI multitasking dataset (Garner & Dux,
% 2015)
% this code is formatted for use with awoonga.qriscloud cluster
% with each individual subject data
% each processing step is output into the specific preprocessing folder of
% the same name (directory is written by bash code for awoonga)
% output = sub_num_
% DC = dicom conversion
% ST = slice-time correction
% R = realign and estimate
% COREG = co-registration
%%%%% MANUAL SECTION: check co-registration
% SEG = segmentation
% NORM = normalise
%%%%% MANUAL SECTION: check normalisation
% SM = smoothed data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%       SET UP ENVIRONMENT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

tmpdir = getenv('TMPDIR');
arr_num = str2num(getenv('PBS_ARRAY_INDEX'));
%tmpdir = '/media/kgarner/HouseShare/multi-dcm-out/';
%cd(tmpdir)
%savedir = '/media/kgarner/KG_MRI_PROC/';
savedir = tmpdir;

addpath '~/spm12';
%jobdir = '/home/kgarner/Dropbox/QBI/mult-conn/multipract-corticostriat-conn/KGarner-pre-processing-multi-dcm-2018-11/';
jobdir = tmpdir;
%job_dir = [tmpdir '/KGarner-pre-processing-multi-dcm-2018-11/'];
% define defaults
spm_jobman('initcfg')
spm('defaults', 'FMRI');

%%% define sub nums
subs = [101:150 201:250];
% ADD NOTES ABOUT ANY EXCEPTIONS HERE
%
% sub nums
%105; % do 2021 and 1332 and 1382 at the end
%%%%% look at these numbers to see the issue
sess_str = [1 2];
nrun = 6;
% options
dcm_convert   = 1;
slice_time    = 1;
realign       = 1;
t1_processing = 1;
co_reg        = 1;
segment       = 1;
normalise     = 1;
smooth        = 1;



for count_sess = 1:2
    
%     if any(dcm_convert)
   sub_fol_source = sprintf([tmpdir, '/sub_%d%d'], subs(arr_num), sess_str(count_sess));
%     else
%         sub_fol_source = sprintf([savedir, '/PREPROC/sub_%d%d'], subs(arr_num), sess_str(count_sess));
%     end
    
   sub_fol_dest = sprintf([savedir, '/sub_%d%d_out'], subs(arr_num), sess_str(count_sess));
    
    if any(dcm_convert)
        
        % for each run, create a specific folder for the new files - in
        % sub_%d_DC/RUN%d and write the new dicom files
        
        for count_runs = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && count_runs <= 2 % are .IMA files not .dcm - NOTE THIS ATTEMPT TO SAVE DID NOT WORK
            else
                DC_fol = sprintf([sub_fol_dest '/RUN%d'], count_runs);
                mkdir(DC_fol);
                dicom_convert_functional;
            end
        end
        % now do the same for the T1 image
        %%%%%%% add batch of dicom import here
        DC_fol = sprintf([sub_fol_dest, '/T13D']);
        mkdir(DC_fol);
        jobfile = {[jobdir '/dicom_convert_structural.m']};
        jobs = jobfile;
        inputs = cell(1, 2);
        inputs{1, 1} = cellstr(spm_select('FPList',fullfile(sub_fol_source,sprintf('T13D/')), file_filt));
        inputs{1, 2} = cellstr(DC_fol);
        spm_jobman('run', jobs, inputs{:});
    end
    
    % now take same inputs for slice timing correction
    if slice_time
        % https://en.wikibooks.org/wiki/SPM/Slice_Timing - states slice
        % timing correction is mandatory for DCM (when TR > 2 seconds)
        jobfile = {[jobdir '/slice_timing.m']};
        file_filt = '^f.*\.nii$';
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(1, nrun);
        for crun = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && crun <= 2
            else
                curr_dir = sprintf([sub_fol_dest '/RUN%d'], crun);
                inputs{1, crun} = cellstr(spm_select('FPList',curr_dir,file_filt)); % Realign: Estimate & Reslice: Session - cfg_files
            end
        end
        spm_jobman('run', jobs, inputs{:});
    end
    
    
    if any(realign)
        
        jobfile = {[jobdir '/realign.m']};
        file_filt = '^af.*\.nii$';
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(1, nrun);
        for crun = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && crun <= 2
            else
                curr_dir = sprintf([sub_fol_dest '/RUN%d'], crun);
                inputs{1, crun} = cellstr(spm_select('FPList',curr_dir,file_filt));
            end
        end
        spm_jobman('run', jobs, inputs{:});
    end
    
    if any(t1_processing)
        
        % first, automatically set origin to AC
        file_filt = '^s.*\.nii$';
        t1_dir = [sub_fol_dest '/T13D'];
        t1_image = char(spm_select('FPList',t1_dir,file_filt));
        auto_reorient(t1_image);
        
        % skull strip, not using
        %     jobfile = {[jobdir 'skull_strip.m']};
        %     jobs = repmat(jobfile, 1, 1);
        %     struct_dir = [sub_fol_dest '/T13D'];
        %     file_filt = '^c1.*\.nii$';
        %     grey_matter = cellstr(spm_select('FPList',struct_dir,file_filt));
        %     file_filt = '^c2.*\.nii$';
        %     white_matter = cellstr(spm_select('FPList',struct_dir,file_filt));
        %     file_filt =  '^s.*\.nii$';
        %     t1_fileName = cellstr(spm_select('FPList',struct_dir,file_filt));
        %     inputs = cell(1, 1);
        %     inputs{1, 1} =  [grey_matter; white_matter; t1_fileName];
        %     spm_jobman('run', jobs, inputs{:});
        
    end
    
    % co-registration
    if any(co_reg)
        % mutual information used to co-register images
        % selecting estimate so that it can be applied in conjunction with
        % normalisation
        jobfile = {[jobdir '/coregistration.m']};
        func_filt = '^meanaf.*\.nii$';
        func_dir = [sub_fol_dest '/'];
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(2, nrun);
        struct_dir = [sub_fol_dest '/T13D'];
        struct_filt = '^s.*\.nii$';
        for crun = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && crun <= 2
            else
                curr_dir = sprintf([func_dir 'RUN%d'], crun);
                inputs{1, crun} = cellstr(spm_select('FPList',curr_dir,func_filt)); % Coregister: Estimate: Reference Image - cfg_files
                inputs{2, crun} = cellstr(spm_select('FPList',struct_dir,struct_filt)); % Coregister: Estimate: Source Image - cfg_files
            end
        end
        spm_jobman('run', jobs, inputs{:});
    end
    
    if any(segment)
        
        jobfile    = {[jobdir '/segment_cluster.m']};
        file_filt  = '^s.*\.nii$';
        struct_dir = [sub_fol_dest '/T13D'];
        tpm_dir    = jobdir;
        tpm_filt   = '^TP.*\.nii$';
        jobs = repmat(jobfile, 1, 1);
        inputs = cell(7, 1);
        inputs{1, 1} =  cellstr(spm_select('FPList',struct_dir,file_filt));
        inputs{2, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',1']));
        inputs{3, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',2']));
        inputs{4, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',3']));
        inputs{5, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',4']));
        inputs{6, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',5']));
        inputs{7, 1} =  cellstr(sprintf([spm_select('FPList',tpm_dir,tpm_filt), ',6']));
        spm_jobman('run', jobs, inputs{:});
    end
    
    if any(normalise)
        % transform functional and structural data to match the MNI space
        jobfile = {[jobdir '/normalise.m']};
        jobs = repmat(jobfile, 1 , nrun);
        inputs = cell(2, nrun);
        image_file_filt = '^raf.*\.nii$';
        mean_file_filt = '^mean.*\.nii$';
        deform_dir = [sub_fol_dest '/T13D'];
        deform_filt = '^y_s.*\.nii$';
        
        for crun = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && crun <= 2
            else
                curr_dir = [sub_fol_dest '/RUN' num2str(crun)];
                functionals = [cellstr(spm_select('FPList',curr_dir,image_file_filt)); ...
                    cellstr(spm_select('FPList',curr_dir,mean_file_filt))];
                inputs{1, crun} = cellstr(spm_select('FPList',deform_dir,deform_filt));
                inputs{2, crun} = functionals;
            end
        end
        spm_jobman('run', jobs, inputs{:});
        
        % apply spatial normalisation to bias-corrected anatomical
        % image
        jobs   = jobfile;
        inputs = cell(2, 1);
        image_file_filt = '^ms.*\.nii$';
        deform_dir = [sub_fol_dest '/T13D'];
        deform_filt = '^y_s.*\.nii$';
        inputs{1, 1} = cellstr(spm_select('FPList',deform_dir,deform_filt));
        inputs{2, 1} = cellstr(spm_select('FPList',deform_dir,image_file_filt));
        spm_jobman('run', jobs, inputs{:});
        
    end
    
    % smoothing
    if any(smooth)
        jobfile = {[jobdir '/smooth.m']};
        file_filt = '^wraf.*\.nii$';
        jobs = repmat(jobfile, 1 , nrun);
        inputs = cell(1, nrun);
        for crun = 1:nrun
            if subs(arr_num) == 138 && count_sess == 2 && crun <= 2
            else
                curr_dir = [sub_fol_dest '/RUN' num2str(crun)];
                inputs{1, crun} = cellstr(spm_select('FPList',curr_dir,file_filt));
            end
        end
        spm_jobman('run', jobs, inputs{:});
    end
    
end
