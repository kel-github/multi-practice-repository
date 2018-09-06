%%%%%%%%%%%% code extracts first eigenvariates from regions of interest for all subjects,
%%%%%%%%%%%% then defines matrices for first DCM and random selection of first participants is here.
%%%%%%%%%%%% defines an SPM with concatenated runs, session is a regressor -
%%%%%%%%%%%% then runs dcm for each participant (B matrices modulated by session factor) and stores results.
%%%%%%%%%%%% will write code post hoc for the models that did not converge
%%%%%%%%%%%% - i.e. priors adjustment
%%%%%%%%%%%% - v2 includes exceptions for participants = 102 & 203 in number of scans to be concatenated	
%%%%%%%%%%%% - v3 version that allows for differing number of runs for the
%%%%%%%%%%%% first and second sessions to account for quirks with subs 138,
%%%%%%%%%%%% 202, 204 & 227, manually concatenates regressors
%%%%%%%%%%%% v4 prints the filepath variables for dcm batch job and output of spm_jobman (for new
%%%%%%%%%%%% cluster testing) and refers to the correct function for
%%%%%%%%%%%% regressor concatenation. it has also removed the functionality
%%%%%%%%%%%% of adding manual regressor for session that was in v3
%%%%%%%%%%%% v5 has new methods of creating contrast masks to define
%%%%%%%%%%%% activity in regions of interest (fits classic GLM and
%%%%%%%%%%%% defines the open vis-man + aud-man contrast - and the sing vs double, as the contrasts
%%%%%%%%%%%% of interest as this is what
%%%%%%%%%%%% was used to initially identify regions of interest - the
%%%%%%%%%%%% timeseries extraction uses the voxels active in this contrast
%%%%%%%%%%%% that are within the anatomically defined masks

clear all
%start = tic
tmpdir = getenv('TMPDIR');
%tmpdir = pwd;
sfol = 'sub_%d_out_s1s2_anatROI_initGLM';

% testing arr_num...
arr_num = str2num(getenv('PBS_ARRAY_INDEX'));

addpath '~/spm12';
% pre proc code for spm - needs to be run from same dir as subj folders
% define defaults
spm_jobman('initcfg')
spm('defaults', 'FMRI');

%%% define sub nums
subs = [101:150 201:250];

%%%%% set run options for each participant
if subs(arr_num) == 138
    n_s1_runs = 6;
    n_s2_runs = 4;
    s1_runs = [1 2 3 4 5 6];
    s2_runs = [3 4 5 6];
elseif subs(arr_num) == 202
    n_s1_runs = 4;
    n_s2_runs = 6;
    s1_runs = [2 3 4 5];
    s2_runs = [1 2 3 4 5 6];
elseif subs(arr_num) == 204
    n_s1_runs = 5;
    n_s2_runs = 6;
    s1_runs = [1 2 3 4 5];
    s2_runs = [1 2 3 4 5 6];
elseif subs(arr_num) == 227
    n_s1_runs = 6;
    n_s2_runs = 5;
    s1_runs = [1 2 3 4 5 6];
    s2_runs = [2 3 4 5 6];
else 
    n_s1_runs = 6;
    n_s2_runs = 6;
    s1_runs = [1 2 3 4 5 6];
    s2_runs = [1 2 3 4 5 6];
end

% options
define_cl_glm  = 1;
est_cl_glm     = 1;
define_contrasts = 1;
extract_time_course = 1;
define_dcm_glm = 1;
nruns = 12;
end_sess_one_run = 6;
define_dcms = 1;

% load the pre-defined the b matrices 
load('b_mats_v4'); % all perms of 5 combos

% regions from which to extract timecourses
nregions = 3;

%%%%% PREPROCESSING
if define_cl_glm
    
     jobfile = {[tmpdir '/glm_def.m']}; % TMPDIR/
     jobs = repmat(jobfile, 1, 1);
     file_filt = '^swa.*\.nii$';
     all_scans = {};
     GLM_prots_v1(subs(arr_num),n_s1_runs,n_s2_runs,s1_runs,s2_runs,tmpdir,sfol);
     % concs for both fstl and dcm
     conc_regressors_SESS_v5(subs(arr_num),n_s1_runs,n_s2_runs,s1_runs,s2_runs,tmpdir,sfol);
     
     sub_fol =  sprintf([tmpdir '/' sfol '/FSTL_GLM'],subs(arr_num));
     inputs{1,1} = cellstr([sub_fol '/']);
    for crun = 1:n_s1_runs
        
      sub_fol =  sprintf('sub_%d%d',subs(arr_num),1);
      run_num = s1_runs(crun);       
      tmp = cellstr(spm_select('FPList',fullfile(sub_fol,sprintf('RUN%d',run_num)),file_filt));
      all_scans = [all_scans; tmp];
      
    end    
    for crun = 1:n_s2_runs
        
      sub_fol =  sprintf('sub_%d%d',subs(arr_num),2);
      run_num = s2_runs(crun);       
      tmp = cellstr(spm_select('FPList',fullfile(sub_fol,sprintf('RUN%d',run_num)),file_filt));
      all_scans = [all_scans; tmp];
      
    end
    inputs{2,1} = all_scans;
    inputs{3,1} = cellstr(fullfile(sprintf([tmpdir '/' sfol '/FSTL_GLM/%d_DCMSPMSESS_onsets.mat'],subs(arr_num),subs(arr_num))));    
    sub_fol =  sprintf([tmpdir '/' sfol '/FSTL_GLM/'],subs(arr_num));
    inputs{4,1} = cellstr(spm_select('FPList',sub_fol,sprintf('%d_moveRegress_allScansSESS1.txt',subs(arr_num))));
    spm_jobman('run',jobs,inputs{:});
    
    %%%%%%%% now concatanate 
    %%%%%%%% now concatanate 
    if subs(arr_num) == 102
        scans = [154 154 154 154 154 154 151 151 151 151 151 151];
    elseif subs(arr_num) == 203
        scans = [154 154 154 154 154 154 154 154 154 154 154 154];
    elseif subs(arr_num) == 202
        scans = [151 151 151 151 151 151 151 151 151 151];
    elseif subs(arr_num) == 138
        scans = [151 151 151 151 151 151 151 151 151 151];
    elseif subs(arr_num) == 204
        scans = [151 151 151 151 151 151 151 151 151 151 151];
    elseif subs(arr_num) == 227
        scans = [151 151 151 151 151 151 151 151 151 151 151];
    else
        scans = [151 151 151 151 151 151 151 151 151 151 151 151];
    end
    spm_fmri_concatenate(fullfile(sub_fol,'SPM.mat'),scans);

end

if est_cl_glm
    
    % maintain_sess_regress(subs(arr_num), tmpdir); % this function prevents the session regressors from having high pass filter applied
    jobfile = {[tmpdir '/glm_est.m']};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(1, 1);
    sub_fol =  sprintf(sfol,subs(arr_num));
    inputs{1,1} = cellstr([sub_fol '/FSTL_GLM/SPM.mat']);
    spm_jobman('run', jobs, inputs{:});
end

%%%%%%%% define SPM including both sessions (pre- and
%%%%%%%% post-training)
if define_dcm_glm
    
    jobfile = {[tmpdir '/dcm_glm_def.m']}; % TMPDIR/
    jobs = repmat(jobfile, 1, 1);
    file_filt = '^swa.*\.nii$';
    all_scans = {};
    %%%%%%%%%%%%%%% compile events and regressors
    DCM_GLM_2SESS_prots_v3(subs(arr_num),n_s1_runs,n_s2_runs,s1_runs,s2_runs,tmpdir,sfol);
    %conc_regressors_SESS_v4(subs(arr_num),n_s1_runs,n_s2_runs,s1_runs,s2_runs,tmpdir);
    %%%%%%%%%%%%%% now make GLM file
    sub_fol =  sprintf([tmpdir '/' sfol '/DCM_GLM'],subs(arr_num));
    inputs{1,1} = cellstr([sub_fol '/']);
    for crun = 1:n_s1_runs       
      sub_fol =  sprintf('sub_%d%d',subs(arr_num),1);
      run_num = s1_runs(crun);       
      tmp = cellstr(spm_select('FPList',fullfile(sub_fol,sprintf('RUN%d',run_num)),file_filt));
      all_scans = [all_scans; tmp];      
    end
    for crun = 1:n_s2_runs        
      sub_fol =  sprintf('sub_%d%d',subs(arr_num),2);
      run_num = s2_runs(crun);       
      tmp = cellstr(spm_select('FPList',fullfile(sub_fol,sprintf('RUN%d',run_num)),file_filt));
      all_scans = [all_scans; tmp];     
    end
    inputs{2,1} = all_scans;
    inputs{3,1} = cellstr(fullfile(sprintf([tmpdir '/' sfol '/DCM_GLM/%d_DCMSPMSESS_onsets.mat'],subs(arr_num),subs(arr_num))));
    
    sub_fol =  sprintf([tmpdir '/' sfol '/DCM_GLM/'],subs(arr_num));
    inputs{4,1} = cellstr(spm_select('FPList',sub_fol,sprintf('%d_moveRegress_allScansBOTHSESS.txt',subs(arr_num))));
    spm_jobman('run',jobs,inputs{:});
    
    %%%%%%%% now concatanate 
    if      subs(arr_num) == 102
            scans = [154 154 154 154 154 154 151 151 151 151 151 151];
    elseif subs(arr_num) == 203
            scans = [154 154 154 154 154 154 154 154 154 154 154 154];
    elseif subs(arr_num) == 202
            scans = [151 151 151 151 151 151 151 151 151 151];
	elseif subs(arr_num) == 138
			scans = [151 151 151 151 151 151 151 151 151 151];
    elseif subs(arr_num) == 204
            scans = [151 151 151 151 151 151 151 151 151 151 151];
    elseif subs(arr_num) == 227
            scans = [151 151 151 151 151 151 151 151 151 151 151];
    else
            scans = [151 151 151 151 151 151 151 151 151 151 151 151];
	end
    spm_fmri_concatenate(fullfile(sub_fol,'SPM.mat'),scans);

end
        
% if estimate_dcm_glm
%     
%     % maintain_sess_regress(subs(arr_num), tmpdir); % this function prevents the session regressors from having high pass filter applied
%     jobfile = {[tmpdir '/glm_est.m']};
%     jobs = repmat(jobfile, 1, 1);
%     inputs = cell(1, 1);
%     sub_fol =  sprintf('sub_%d_out',subs(arr_num));
%     inputs{1,1} = cellstr([sub_fol '/DCM_GLM/SPM.mat']);
%     spm_jobman('run', jobs, inputs{:});
% end

%%%%%%% step 2 - define contrasts
if define_contrasts
    sub_fol =  sprintf([sfol '/FSTL_GLM'],subs(arr_num));
    jobfile = {[tmpdir '/dcm_def_contrasts_wSESS_v3.m']};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(1,1);
    inputs{1,1} = cellstr([sub_fol '/SPM.mat']);
    spm_jobman('run', jobs, inputs{:});
end
        
%%%%%%%% step 3 - extract time course
if extract_time_course
    
    sub_fol =  sprintf([sfol '/FSTL_GLM'],subs(arr_num));
    jobfile = {[tmpdir '/extract_time_course_wAnat.m']};
    jobs = repmat(jobfile, 1, 1);
    inputs = cell(nregions*2, 1);
    inputs{1,1} = cellstr([sub_fol '/SPM.mat']);
    inputs{2,1} = cellstr([tmpdir '/antIPS_HP1L_juelich_prob_thresh5_bin.nii']);
    inputs{3,1} = cellstr([sub_fol '/SPM.mat']);
    inputs{4,1} = cellstr([tmpdir '/lput_harv_oxf_cortical_thresh5_bin.nii']);
    inputs{5,1} = cellstr([sub_fol '/SPM.mat']);
    inputs{6,1} = cellstr([tmpdir '/sma_harv_oxf_cortical_thresh5_bin.nii']);
    spm_jobman('run', jobs, inputs{:});
    cd(getenv('TMPDIR'));   
end
        
%%%%%________________________________________________ DEFINE DCM
if define_dcms
    %       fprint('ESTIMATING DCMs for sub %d of %d', count_subs, length(ref));
    % cd '~/Desktop/MRI/'
    % testing data path
    data_path = sprintf([tmpdir '/' sfol], subs(arr_num));
    %sub_path = sprintf('sub_%d_out',subs(arr_num));
    clear DCM SPM
    %%%%%% load SPM
    load(fullfile(data_path,'DCM_GLM','SPM.mat'));

    % Load regions of interest
    % % xY contains the following fields:
    %  xY     - VOI structure
    %        xY.xyz          - centre of VOI {mm}
    %        xY.name         - name of VOI
    %        xY.Ic           - contrast used to adjust data (0 - no adjustment)
    %        xY.Sess         - session index
    %        xY.def          - VOI definition
    %        xY.spec         - VOI definition parameters
    %        xY.XYZmm        - Co-ordinates of VOI voxels {mm}
    %        xY.y            - [whitened and filtered] voxel-wise data
    %        xY.u            - first eigenvariate {scaled - c.f. mean response}
    %        xY.v            - first eigenimage
    %        xY.s            - eigenvalues
    %        xY.X0           - [whitened] confounds (including drift terms)
    %--------------------------------------------------------------------------
    
    % DCM structure
    % DCM.M      - model  specification structure (see spm_nlsi)
    % DCM.Y      - output specification structure (see spm_nlsi)
    % DCM.U      - input  specification structure (see spm_nlsi)
    % DCM.Ep     - posterior expectations (see spm_nlsi)
    % DCM.Cp     - posterior covariances (see spm_nlsi)
    % DCM.A      - intrinsic connection matrix
    % DCM.B      - input-dependent connection matrix
    % DCM.C      - input connection matrix
    % DCM.pA     - pA - posterior probabilities
    % DCM.pB     - pB - posterior probabilities
    % DCM.pC     - pC - posterior probabilities
    % DCM.vA     - vA - variance of parameter estimates
    % DCM.vB     - vB - variance of parameter estimates
    % DCM.vC     - vC - variance of parameter estimates
    % DCM.H1     - 1st order Volterra Kernels - hemodynamic
    % DCM.H2     - 1st order Volterra Kernels - hemodynamic
    % DCM.K1     - 1st order Volterra Kernels - neuronal
    % DCM.K1     - 1st order Volterra Kernels - neuronal
    % DCM.R      - residuals
    % DCM.y      - predicted responses
    % DCM.xY     - original response variable structures
    % DCM.T      - threshold for inference based on posterior p.d.f
    % DCM.Ce     - Estimated observation noise covariance
    % DCM.v      - Number of scans
    % DCM.n      - Number of regions
    
    load(fullfile(data_path,'FSTL_GLM','VOI_LIPL_1.mat'),'xY');
    DCM.xY(1) = xY;
    load(fullfile(data_path,'FSTL_GLM','VOI_LPut_1.mat'),'xY');
    DCM.xY(2) = xY;
    load(fullfile(data_path,'FSTL_GLM','VOI_SMFC_1.mat'),'xY');
    DCM.xY(3) = xY;
    
    DCM.n = length(DCM.xY);      % number of regions
    DCM.v = length(DCM.xY(1).u); % number of time points
    
    % Time series
    %--------------------------------------------------------------------------
    DCM.Y.dt  = SPM.xY.RT; % SPM.xY.RT  - TR length
    DCM.Y.X0  = DCM.xY(1).X0;  % confounds first VOI
    for i = 1:DCM.n
        DCM.Y.y(:,i)  = DCM.xY(i).u; % take first eigenvariate of each VOI
        DCM.Y.name{i} = DCM.xY(i).name; % get the name of the VOI
    end
    DCM.Y.Q = spm_Ce(ones(1,DCM.n)*DCM.v); % get error covariance constraints
    
    % Experimental inputs (session)
    %--------------------------------------------------------------------------
    DCM.U.dt   =  SPM.Sess.U(1).dt;
    DCM.U.name =  SPM.Sess.U(1).name;
    %DCM.U.u    =  SPM.Sess.U(1).u(33:end,1); 
    DCM.U.u    = [SPM.Sess.U(1).u(33:end,1) ...
                  SPM.Sess.U(2).u(33:end,1) ...
                  SPM.Sess.U(3).u(33:end,1)];
    
    % DCM parameters and options
    %--------------------------------------------------------------------------
    DCM.delays = repmat(SPM.xY.RT/2,DCM.n,1);
    DCM.TE     = 0.035;
    
    DCM.options.nonlinear  = 0;
    DCM.options.two_state  = 0;
    DCM.options.stochastic = 0;
    DCM.options.nograph    = 1;
    
    % Define DCM matrices
    %--------------------------------------------------------------------------
    count_all_dcms = 0;
    dcm_fname_ref = [];
    
    [~,~,total_prac_mats] = size(b_mats); % total number of b mats for practice factor
    % extrinsic connections (= always same)
    DCM.a = [1 1 1; ...
             1 1 1; ...
             0 1 1];
    DCM.d = zeros(3,3,0); % no non-linear connections
    %%%%%%%%%%%%%%%%% instead of batching all dcm's, need to
    %%%%%%%%%%%%%%%%% estimate 1 at a time, so that can add
    %%%%%%%%%%%%%%%%% convergence info to dcm structure
    
    % Connectivity matrices for LPut input
    % %   -------------------------------------------------------------------------
    DCM.c = [0 0 0; ...
             1 0 0;
             0 0 0]; % input to LPut
    

         for count_prac_mats = 1:total_prac_mats
             clear matlabbatch
             DCM.b = zeros(3,3,3); % base - no modulatory
             DCM.b(:,:,2) = [0, 1, 1;...
                             1, 0, 1;...
                             0, 1, 0];% winning model from session 1
             DCM.b(:,:,3) = b_mats(:,:,count_prac_mats); % add mod practice
             dcm_name = sprintf('DCM_LPut_inp_winb_prac%d.mat', count_prac_mats);
             save(fullfile(data_path, 'DCM_OUT', dcm_name),'DCM');
             dcm_fname_ref = fullfile(data_path, 'DCM_OUT', dcm_name);
             matlabbatch{1}.spm.dcm.fmri.estimate.dcmmat = cellstr(dcm_fname_ref);
             spm_jobman('run',matlabbatch);
         end

end
