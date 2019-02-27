function [] = plot_grp_level_params(dat, idx, colours, pos_idx, mus, prctiles, x_range)
%%%% function plots group level posteriors over parameters, given inidvidual model
%%%% probabilities per subject
%%%% dat = a n x m matrix of posterior estimates for b parameters, n =
%%%% connections, m = estimates
%%%% idx - logical indexing for desired connections from bs
%%%% colours - 2 x 3 matrix, row 1 = face colour, 2 = line colour, rgb values
%%%% rows, cols, = t row and columns for subplot
%%%% mus, = mean parameter value for each connection
%%%% prctiles = n x m x 2 matrix - dim 3 contains .275 and .975 prctiles for each posterior
%%%% x_range = xlims, enter 9 to not adjust by the x_range
rows = [1 1 1; ...
        2 2 2; ...
        3 3 3];
cols = [1 2 3; ...
        1 2 3; ...
        1 2 3];
for count_idx = 1:length(idx)
    
    subplot('position', pos_idx(:,count_idx)');
    histogram(dat(rows(idx(count_idx)), cols(idx(count_idx)), :), 'Normalization', 'probability', ...
        'FaceColor', colours(1,:)/255, 'EdgeColor', 'none')
    ylim([0, .08]);
    if x_range ~= 9
        if count_idx > 1 && count_idx < 4
            set(gca,'xticklabel',{[]}, 'yticklabel',{[]});
        elseif count_idx == 4
            set(gca,'xticklabel',{[]});
        elseif count_idx > 4
            set(gca,'xticklabel',{[]}, 'yticklabel',{[]});
        end
    elseif x_range == 9
        if count_idx > 1 && count_idx < 4
            set(gca,'yticklabel',{[]});
        elseif count_idx > 4
            set(gca,'yticklabel',{[]});
        end 
    end
    % add y label and x label
    
    % add mu and CIs
    cur_axes = gca;
    line([mus(rows(idx(count_idx)), cols(idx(count_idx))), mus(rows(idx(count_idx)), cols(idx(count_idx)))], get(cur_axes, 'YLim'), 'Color',  colours(2,:)/255,...
        'LineStyle', '-', 'LineWidth', 1.2);
    line([prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1), prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1)], get(cur_axes, 'YLim'), 'Color', colours(2,:)/255,...
        'LineStyle', '-');
    line([prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2), prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2)], get(cur_axes, 'YLim'), 'Color',  colours(2,:)/255,...
        'LineStyle', '-');
    line([0, 0], get(cur_axes, 'YLim'), 'Color', [0, 0, 0],...
        'LineStyle', ':');
    if x_range ~= 9
        xlim(x_range);
    end

    if count_idx == 1
        ylabel('p(x)');
        xlabel('');
    elseif count_idx > 1 && count_idx < 4
        ylabel('');
        xlabel('');
    elseif count_idx == 4
        ylabel('p(x)');
        xlabel('');
    elseif count_idx > 4
        ylabel('');
        xlabel('');
    end
    
    box off

end

end