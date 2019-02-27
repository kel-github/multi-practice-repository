function [a, a_mus, a_prctiles, b, b_mus, b_sds, b_prctiles] = get_grpLevel_params_by_grp_v2(bms_fname, pdim, conf_intervals)
% v2 allows automated selection of the b matrix on the z dimension
% function to pull out A and B params for each group
% input bms file to get the group level mean, posterior and prctiles (2.5 &
% 97.5) of the group level a and b params
load(bms_fname)
a_mus      = BMS.DCM.rfx.bma.mEp.A;
a          = BMS.DCM.rfx.bma.a;
a_prctiles = prctile(a, conf_intervals, 3);

b_mus       = BMS.DCM.rfx.bma.mEp.B(:,:,pdim);
b_sds       = BMS.DCM.rfx.bma.sEp.B(:,:,pdim);
b           = squeeze(BMS.DCM.rfx.bma.b(:,:,pdim,:));
b_prctiles  = prctile(b, conf_intervals, 3);
end


