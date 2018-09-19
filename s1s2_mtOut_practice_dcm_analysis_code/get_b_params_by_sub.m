function [data] = get_b_params_by_sub(BMS, m, n, z, sub_nums)

data = [];

for i = 1:length(BMS.DCM.rfx.bma.mEps)
    if sub_nums(i) < 199
        group = 1;
    else
        group = 2;
    end
    
    for get_params = 1:length(m)
        
        data = [data; sub_nums(i) group get_params BMS.DCM.rfx.bma.mEps{i}.B(m(get_params), n(get_params), z)];
    end
    
end    
end