%-----------------------------------------------------------------------
% Job saved on 31-Jan-2016 16:32:15 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
% v2 includes only effects of interest contrast
% v3 in this folder regresses out multitask trials
matlabbatch{1}.spm.stats.con.spmmat = '<UNDEFINED>';
matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'open-sing';
matlabbatch{1}.spm.stats.con.consess{1}.fcon.weights = eye(2);
matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;

matlabbatch{1}.spm.stats.con.consess{2}.fcon.name = 'effectsOfInt';
matlabbatch{1}.spm.stats.con.consess{2}.fcon.weights = eye(4);
matlabbatch{1}.spm.stats.con.consess{2}.fcon.weights(:,3) = 0;
matlabbatch{1}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.delete = 0;