function [b_correlation_matrix, Meff, alpha_Meff] = Meff_correction(params, idx, param_idx)
% K. Garner, November 2018
% this function takes the subject mean B parameters from the spm DCM output
% structure, and outputs  a variable correlation matrix. The function then
% computes the Meff correction factor, and the Meff corrected alpha level
% formulae taken from Derringer, J. 2018. A simple correction for
% nonindependent tests
% input = params = BMS.DCM.rfx.bma.mEps (i.e. the nsub cell array of
% participant param values
% idx = matrix indexing for required parameters
% param idx = 1 to test between b parameters, 2 to test between a parameters
k = length(idx);
sub_bs = zeros(length(params), length(idx));

for count_subs = 1:length(params)
    if param_idx == 1
        this_b = params{count_subs}.B(:,:,2);
    else
        this_b = params{count_subs}.A;
    end
    for count_params = 1:length(idx)

        sub_bs(count_subs, count_params) = this_b(idx(count_params));
    end
end

b_correlation_matrix = corr(sub_bs);
eigs_b_corr_mat      = eig(b_correlation_matrix)';

Meff = 1 + ( (k-1) * (1 - (var(eigs_b_corr_mat)/k)) );
alpha_Meff = .05/Meff;

end