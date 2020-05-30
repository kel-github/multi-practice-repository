function [] = plot_grp_level_params(dat, idx, rows, cols, mus, prctiles, x_range, titles, top_tit)

figure;
for count_idx = 1:length(idx)
    
    subplot(3, 3, idx(count_idx))
    histogram(dat(rows(count_idx), cols(count_idx), :), 'Normalization', 'probability', ...
        'FaceColor', [255, 128, 0]/255, 'EdgeColor', 'none')
    
    % add mu and CIs
    cur_axes = gca;
    line([mus(rows(count_idx), cols(count_idx)), mus(rows(count_idx), cols(count_idx))], get(cur_axes, 'YLim'), 'Color', [0, 0, 153]/255,...
        'LineStyle', '-', 'LineWidth', 1.2);
    line([prctiles(rows(count_idx), cols(count_idx), 1), prctiles(rows(count_idx), cols(count_idx), 1)], get(cur_axes, 'YLim'), 'Color', [0, 0, 153]/255,...
        'LineStyle', '--');
    line([prctiles(rows(count_idx), cols(count_idx), 2), prctiles(rows(count_idx), cols(count_idx), 2)], get(cur_axes, 'YLim'), 'Color', [0, 0, 153]/255,...
        'LineStyle', '--');
    line([0, 0], get(cur_axes, 'YLim'), 'Color', [0, 0, 0],...
        'LineStyle', ':');
    xlim(x_range);
    title(titles{count_idx});
end
suptitle(top_tit)
end