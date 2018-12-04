function DCM_GLM_2SESS_prots_v3(sub,n_s1_runs, n_s2_runs, s1_runs, s2_runs, fpath,sfol)
%%%%%%% code writes a new matfile for each participant, adding the onsets
%%%%%%% onto one another for concatenation test - needs to be run from
%%%%%%% directory where the mat file should be saved
%%%%%%% v2 for sub quirks (see dcm_analysis_v3)
%%%%%%% v3 concatenates onsets for two regressors "MULTI",
%%%%%%% "PRACTICE"

all_durs = {};
all_ons = {};

if sub == 138
    adds = [151 302 453 604 755 906 1057 1208 1359];
elseif sub == 202
    adds = [151 302 453 604 755 906 1057 1208 1359];
elseif sub == 204
    adds = [151 302 453 604 755 906 1057 1208 1359 1510];
elseif sub == 227
    adds = [151 302 453 604 755 906 1057 1208 1359 1510];
else
    adds = [151 302 453 604 755 906 1057 1208 1359 1510 1661];
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
                % now take the onsets of all events (for regressor: ALL)
                all_ons{1} = [onsets{3}];
                all_durs{1} = [durations{3}];
            else
                % if not the 1st run, add the approp number of runs to the
                % data
                for y = 1:length(onsets)
                    onsets{y} = onsets{y} + adds(count_adds);
                end
                
                % as above - take all onsets for the ALL regressor
                all_ons{1} = [all_ons{1} onsets{3}];
                all_durs{1} = [all_durs{1} durations{3}];

            end
    end

    for x = 1:n_s2_runs
    
        count_adds = count_adds + 1;
        %load(sprintf([fpath '/Training_fMRI_%d%d_run0%d.mat'],sub,2,s2_runs(x)));
        load(sprintf(['Training_fMRI_%d%d_run0%d.mat'],sub,2,s2_runs(x)));
            for y = 1:length(onsets)
                onsets{y} = onsets{y} + adds(count_adds);
            end
            
            % as above - take all onsets for the ALL regressor
            all_ons{1} = [all_ons{1} onsets{3}];
            all_durs{1} = [all_durs{1} durations{3}];          
            
            % now take all the onsets for the session regressor
            if x == 1
                all_ons{2} = onsets{3};
                all_durs{2} = durations{3};

            else
                all_ons{2} = [all_ons{2} onsets{3}];
                all_durs{2} = [all_durs{2} durations{3}];
            end
     end

names = {'multi','practice'};
onsets = all_ons;
durations = all_durs;

save(sprintf([fpath '/' sfol '/DCM_GLM/%d_DCMSPMSESS_onsets.mat'],sub,sub),'names','durations','onsets');
    
    
