function S1_DCM_prots_v1(sub,n_s1_runs, s1_runs, fpath)
%%%%%%% code writes a new matfile for each participant, adding the onsets
%%%%%%% onto one another for concatenation test - needs to be run from
%%%%%%% directory where the mat file should be saved
%%%%%%% v2 for sub quirks (see dcm_analysis_v3)
%%%%%%% v3 concatenates onsets for three regressors "ALL", "MULTI",
%%%%%%% "PRACTICE"

all_durs = {};
all_ons = {};

if sub == 138
    adds = [151 302 453 604 755];
elseif sub == 202
    adds = [151 302 453];
elseif sub == 204
    adds = [151 302 453 604];
elseif sub == 227
    adds = [151 302 453 604 755];
else
    adds = [151 302 453 604 755];
end

%%%%%%%%%%%%%% do s1
count_adds = 0;
    for x = 1:n_s1_runs
    
        if x == 1
        else
            count_adds = count_adds + 1;
        end
        
        % load th eparticipant file for that run
        load(sprintf(['Training_fMRI_%d%d_run0%d.mat'],sub,1,s1_runs(x)));
            if x == 1
                % if it is the 1st run, take the value of each onset
                % (for three regressors: the two single + multi)
                all_ons{1} = [onsets{1} onsets{2} onsets{3}];  
                all_ons{2} = [onsets{3}];
                all_durs{1} = [durations{1}  durations{2}  durations{3}];
                all_durs{2} = durations{3};

            else
                % if not the 1st run, add the approp number of runs to the
                % data
                for y = 1:length(onsets)
                    onsets{y} = onsets{y} + adds(count_adds);
                end
                
                % as above - take all onsets for each regressor
                all_ons{1} = [all_ons{1} onsets{1} onsets{2} onsets{3}];
                all_ons{2} = [all_ons{2} onsets{3}];
                all_durs{1} = [all_durs{1} durations{1} durations{2} durations{3}];
                all_durs{2} = [all_durs{2} durations{3}];

            end
    end

 

names = {'sing','multi'};
onsets = all_ons;
durations = all_durs;

save(sprintf([fpath '/sub_%d_out_anatROI_initGLM/DCM_GLM/%d_DCMSPMSESS_onsets.mat'],sub,sub),'names','durations','onsets');
    
    
