%-----------------------------------------------------------------------
% Job saved on 27-Feb-2016 12:38:37 by cfg_util (rev $Rev: 6460 $)
% spm SPM - SPM12 (6685)
% cfg_basicio BasicIO - Unknown

% code modelled on https://jacoblee.net/occamseraser/2018/01/03/extracting-rois-for-ppi-analysis-using-spm-batch/index.html
% to find the maximal peak with the voxels that are activated by the open
% contrast within the given anatomical mask
% currently set to follow parameters for extraction as happened in this paper:
% http://www.jneurosci.org/content/jneuro/30/9/3210.full.pdf
%-----------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LIPL
matlabbatch{1}.spm.util.voi.spmmat = '<UNDEFINED>';
matlabbatch{1}.spm.util.voi.adjust = 2;
matlabbatch{1}.spm.util.voi.session = 1;
matlabbatch{1}.spm.util.voi.name = 'LIPL';
matlabbatch{1}.spm.util.voi.roi{1}.spm.spmmat = {''}; % assuming is populated by above
matlabbatch{1}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{1}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{1}.spm.util.voi.roi{1}.spm.thresh = .05;
matlabbatch{1}.spm.util.voi.roi{1}.spm.extent = 0; % in voxels
% The mask bounding the ROI's mask.
matlabbatch{1}.spm.util.voi.roi{2}.mask.image = '<UNDEFINED>';
% The extracted ROI's mask. Note how it references the second image as
% its mask. 'move.local' is used to move to nearest local maximum
% in mask. Use 'move.global' to instead move to largest peak in mask.
matlabbatch{1}.spm.util.voi.roi{3}.sphere.centre = [0 0 0]; % not used
matlabbatch{1}.spm.util.voi.roi{3}.sphere.radius = 4; % in mm
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
matlabbatch{1}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
matlabbatch{1}.spm.util.voi.expression = 'i1 & i3';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LPut
matlabbatch{2}.spm.util.voi.spmmat = '<UNDEFINED>';
matlabbatch{2}.spm.util.voi.adjust = 2;
matlabbatch{2}.spm.util.voi.session = 1;
matlabbatch{2}.spm.util.voi.name = 'LPut';
matlabbatch{2}.spm.util.voi.roi{1}.spm.spmmat = {''}; % assuming is populated by above
matlabbatch{2}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{2}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{2}.spm.util.voi.roi{1}.spm.thresh = .05;
matlabbatch{2}.spm.util.voi.roi{1}.spm.extent = 0;
% The mask bounding the ROI's mask.
matlabbatch{2}.spm.util.voi.roi{2}.mask.image = '<UNDEFINED>';
% The extracted ROI's mask. Note how it references the second image as
% its mask. 'move.local' is used to move to nearest local maximum
% in mask. Use 'move.global' to instead move to largest peak in mask.
matlabbatch{2}.spm.util.voi.roi{3}.sphere.centre = [0 0 0]; % not used
matlabbatch{2}.spm.util.voi.roi{3}.sphere.radius = 4;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
matlabbatch{2}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
matlabbatch{2}.spm.util.voi.expression = 'i1 & i3';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SMFC
matlabbatch{3}.spm.util.voi.spmmat = '<UNDEFINED>';
matlabbatch{3}.spm.util.voi.adjust = 2;
matlabbatch{3}.spm.util.voi.session = 1;
matlabbatch{3}.spm.util.voi.name = 'SMFC';
matlabbatch{3}.spm.util.voi.roi{1}.spm.spmmat = {''}; % assuming is populated by above
matlabbatch{3}.spm.util.voi.roi{1}.spm.contrast = 1;
matlabbatch{3}.spm.util.voi.roi{1}.spm.threshdesc = 'none';
matlabbatch{3}.spm.util.voi.roi{1}.spm.thresh = .05;
matlabbatch{3}.spm.util.voi.roi{1}.spm.extent = 0;
% The mask bounding the ROI's mask.
matlabbatch{3}.spm.util.voi.roi{2}.mask.image = '<UNDEFINED>';
% The extracted ROI's mask. Note how it references the second image as
% its mask. 'move.local' is used to move to nearest local maximum
% in mask. Use 'move.global' to instead move to largest peak in mask.
matlabbatch{3}.spm.util.voi.roi{3}.sphere.centre = [0 0 0]; % not used
matlabbatch{3}.spm.util.voi.roi{3}.sphere.radius = 4;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.local.spm = 1;
matlabbatch{3}.spm.util.voi.roi{3}.sphere.move.local.mask = 'i2';
matlabbatch{3}.spm.util.voi.expression = 'i1 & i3';


