clear all
%%% K. Garner, May 21st 2018. Defining b matrix space
% have written new function as old one had removed some of the combinations in error
% saves the b_mats in a file called b_mats_v3
% v4 - excludes the parameters that did not survive the session 1 analysis
%           from
%           lipl lput smfc
%to lipl    1     4    7
%   lput    2     5    8
%   smfc    3     6    9
%%%%% lipl_to_smfc = 3; % not included
smfc_to_lipl = 7;
lipl_to_lput = 2;
lput_to_lipl = 4;
smfc_to_lput = 8;
lput_to_smfc = 6;

conns = [smfc_to_lipl, lipl_to_lput, lput_to_lipl, smfc_to_lput, lput_to_smfc];
base = zeros(3,3);
b_mats = [];
count_mats = 0;
for count = 1:length(conns)
    a = nchoosek(conns, count);
    for perms = 1:size(a,1)
        count_mats = count_mats + 1;
        tmp = base;
        tmp(a(perms,:)) = 1;
        b_mats(:,:,count_mats) = tmp;
    end
end

save('b_mats_v4', 'b_mats');
