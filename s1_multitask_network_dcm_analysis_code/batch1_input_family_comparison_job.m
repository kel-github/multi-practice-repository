%-----------------------------------------------------------------------
% Job saved on 27-Aug-2018 13:25:53 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.dcm.bms.inference.dir = {[dat_fol '/input_family_comparison']};
matlabbatch{1}.spm.dcm.bms.inference.sess_dcm = {};
matlabbatch{1}.spm.dcm.bms.inference.model_sp = {[dat_fol '/input_family_comparison/all_subs_allmodels_input_test.mat']};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = 'RFX';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family_file = {[dat_fol '/input_family_comparison/fam_idxs_q1_input_v1.mat']};
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_no = 0;
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;
spm_jobman('run', matlabbatch);