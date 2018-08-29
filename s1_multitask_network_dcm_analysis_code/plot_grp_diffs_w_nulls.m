function [] = plot_grp_diffs_w_nulls(idx, rows, cols, diff_dist, train_mu, ctrl_mu, x_range, titles, top_tit)

% first compute mean and 95% percentiles
mus       = mean(diff_dist, 3);
prctiles  = prctile(diff_dist, [2.5, 97.5], 3);
obs_diffs = train_mu - ctrl_mu;

figure;
for count_idx = 1:length(idx)
    
    subplot(3, 3, idx(count_idx))
    histogram(diff_dist(rows(count_idx), cols(count_idx), :), 'Normalization', 'probability', ...
        'FaceColor', [192, 192, 192]/255, 'EdgeColor', [192, 192, 192]/255)
    hold on
    xlim(x_range);
    title(titles{count_idx});
    
    %%%%%%%% now add mu's and CIs 
        % add mu and CIs
    cur_axes = gca;
    % train grp
    line([mus(rows(count_idx), cols(count_idx)), mus(rows(count_idx), cols(count_idx))], get(cur_axes, 'YLim'), 'Color', [96, 96, 96]/255,...
        'LineStyle', '-', 'LineWidth', 1.2);
    line([prctiles(rows(count_idx), cols(count_idx), 1), prctiles(rows(count_idx), cols(count_idx), 1)], get(cur_axes, 'YLim'), 'Color', [96, 96, 96]/255,...
        'LineStyle', '--');
    line([prctiles(rows(count_idx), cols(count_idx), 2), prctiles(rows(count_idx), cols(count_idx), 2)], get(cur_axes, 'YLim'), 'Color', [96, 96, 96]/255,...
        'LineStyle', '--');
    % add line for observed difference
    line([obs_diffs(rows(count_idx), cols(count_idx)), obs_diffs(rows(count_idx), cols(count_idx))], get(cur_axes, 'YLim'), 'Color', [255, 151, 151]/255,...
        'LineStyle', '-', 'LineWidth', 1.5);
    
end
suptitle(top_tit);
end

