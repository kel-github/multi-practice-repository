% this code looks up the dicom files for each run and converts them using
% spm functions
file_filt = '^*\.dcm';
dicomFileNames = char(spm_select('FPList',fullfile(sub_fol_source,sprintf('RUN%d/',count_runs)), file_filt));
dicomHeaders   = spm_dicom_headers(dicomFileNames, 1);
spm_dicom_convert(dicomHeaders, 'all', 'flat', 'nii', DC_fol);