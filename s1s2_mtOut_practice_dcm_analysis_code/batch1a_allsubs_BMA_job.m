%-----------------------------------------------------------------------
% Job saved on 06-Sep-2018 12:55:59 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.dcm.bms.inference.dir = {[dat_fol '/allsubs']};
matlabbatch{1}.spm.dcm.bms.inference.sess_dcm = {};
matlabbatch{1}.spm.dcm.bms.inference.model_sp = {[dat_fol '/allsubs/allsubs_allmodels_s1s2_s1winB_multRegOut.mat']};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = 'RFX';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family_file = {''};
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_famwin = 'famwin';
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;
spm_jobman('run', matlabbatch);
