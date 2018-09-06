function [a, a_mus, a_prctiles, b, b_mus, b_sds, b_prctiles] = get_grpLevel_params_by_grp(bms_fname)
% function to pull out A and B params for each group
% input bms file to get the group level mean, posterior and prctiles (2.5 &
% 97.5) of the group level a and b params
load(bms_fname)
a_mus      = BMS.DCM.rfx.bma.mEp.A;
a          = BMS.DCM.rfx.bma.a;
a_prctiles = prctile(a, [2.5, 97.5], 3);

b_mus       = BMS.DCM.rfx.bma.mEp.B(:,:,2);
b_sds       = BMS.DCM.rfx.bma.sEp.B(:,:,2);  
b           = squeeze(BMS.DCM.rfx.bma.b(:,:,2,:));
b_prctiles  = prctile(b, [2.5, 97.5], 3);
end


