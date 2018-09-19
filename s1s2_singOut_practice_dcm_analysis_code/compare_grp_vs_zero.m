function [prob] = compare_grp_vs_zero(n, m, grp_a_mus, grp_a_sds)

prob = [];
grp_a_var = grp_a_sds.^2;

for count = 1:length(n)

   mu_diff = grp_a_mus(n(count), m(count));
   vars    = grp_a_var(n(count), m(count));
    
   prob(count) = 1-spm_Ncdf(0, abs(mu_diff), vars); 
end
end