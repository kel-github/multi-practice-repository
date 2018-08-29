function [out_dist] = permute_params_for_two_sample_test(b1, b2, n)

% this function will take the two vectors (b1 and b2), and over n
% iterations, will randomly shuffle them and pull out the mean difference
% between the two. The n differences become the output vector

data     = [b1 b2];
out_dist = zeros(1,n);
for i = 1:n
   
   all_samp = datasample(data,length(data), 'Replace', false); 
   samp_a = all_samp(1:(length(all_samp)/2));
   samp_b = all_samp(((length(all_samp)/2)+1):length(all_samp));
   out_dist(i) = mean(samp_a) - mean(samp_b);
    
end
end