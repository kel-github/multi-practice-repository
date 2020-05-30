%-----------------------------------------------------------------------
% Job saved on 27-Aug-2018 15:55:26 by cfg_util (rev $Rev: 6942 $)
% spm SPM - SPM12 (7219)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear matlabbatch
matlabbatch{1}.spm.dcm.bms.inference.dir = {[dat_fol '/connection_family_comparison/control_analyses/ctrl_BMS']};
matlabbatch{1}.spm.dcm.bms.inference.sess_dcm = {};
matlabbatch{1}.spm.dcm.bms.inference.model_sp = {[dat_fol '/connection_family_comparison/control_analyses/ctrl_grp_allmodels_cortconn_test.mat']};
matlabbatch{1}.spm.dcm.bms.inference.load_f = {''};
matlabbatch{1}.spm.dcm.bms.inference.method = 'RFX';
matlabbatch{1}.spm.dcm.bms.inference.family_level.family_file = {[dat_fol '/connection_family_comparison/fam_idxs_q2_cortconn_v1.mat']};
matlabbatch{1}.spm.dcm.bms.inference.bma.bma_yes.bma_famwin = 'famwin';
matlabbatch{1}.spm.dcm.bms.inference.verify_id = 1;
spm_jobman('run', matlabbatch)