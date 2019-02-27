function []=plot_family_posteriors(posts, cols, alpha, leg_on, exc_probs, y_on, leg_loc, leg_or, font_size, annotation_location)
% this function produces a histogram plot of posterior densitites obtained
% via family inference using BMS in SPM 12
% posts = a n x m matrix of estimates from sampled posterior distributions
% n = samples, m = distributions
% cols = a m x 3 vector of rgb values for histogram face colours
% alpha = a single value of proportion of alpha for face colours
% leg_on = print legen with exceedance probabilities? 1 for yes, 0 for no
% exc_probs = a m value vector, containing the exceedance probability for
% each distribution
% leg_loc = a string determining legend location
% leg_or = a string to determine whether legend location is horizontal or
% vertical
if nargin < 10
    annotation_location = [];
end

for i = 1:size(posts, 2)
    h(i) = histogram(posts(:, i), 'Normalization', 'probability');
    if i == 1
        hold on
        xlim([0,1]);
        %xlabel('p(f|m)', 'Fontsize', font_size); 
        if ~isempty(annotation_location)
            annotation('textbox', annotation_location,'String','p(f|Y)','EdgeColor','none')
        end
        if ~any(y_on)
            ylabel('');
        else
            ylabel('p(x)', 'Fontsize', font_size);
        end

    end
    
    set(h(i), 'FaceColor', cols(i,:)/255, 'FaceAlpha', alpha, 'EdgeColor', cols(i,:)/255) 

end

if any(leg_on)
    str = sprintf('%c ', 900:1000); % this prints out a bunch of greek characters, so I
    % can get phi
    phi = str(133);
    for i = 1:size(posts, 2)
        leg_str{i} = sprintf([phi '_%d = %.2f'], i, exc_probs(i));
    end
    legend(leg_str, 'location', leg_loc, 'Fontsize',  font_size, 'Orientation', leg_or); %, 'NumColumns', 2);
    legend boxoff

end

    set(gca, 'TickLength',[0 0]);
    box off
end
