function [] = plot_grp_level_by_grp(idx, rows, cols, train_post, train_mu, train_prctiles, ctrl_post, ctrl_mu, ctrl_prctiles, x_range, titles, top_tit)
figure;
for count_idx = 1:length(idx)
    
    subplot(3, 3, idx(count_idx))
    histogram(train_post(rows(count_idx), cols(count_idx), :), 'Normalization', 'probability', ...
        'FaceColor', [255, 128, 0]/255, 'EdgeColor', [255, 128, 0]/255)
    hold on
    histogram(ctrl_post(rows(count_idx), cols(count_idx), :),  'Normalization', 'probability', ...
        'FaceColor', [102, 102, 255]/255, 'EdgeColor', [102, 102, 255]/255)
    xlim(x_range);
    title(titles{count_idx});
    
    %%%%%%%% now add mu's and CIs
        % add mu and CIs
    cur_axes = gca;
    % train grp
    line([train_mu(rows(count_idx), cols(count_idx)), train_mu(rows(count_idx), cols(count_idx))], get(cur_axes, 'YLim'), 'Color', [204, 102, 0]/255,...
        'LineStyle', '-', 'LineWidth', 1.2);
    line([train_prctiles(rows(count_idx), cols(count_idx), 1), train_prctiles(rows(count_idx), cols(count_idx), 1)], get(cur_axes, 'YLim'), 'Color', [204, 102, 0]/255,...
        'LineStyle', '--');
    line([train_prctiles(rows(count_idx), cols(count_idx), 2), train_prctiles(rows(count_idx), cols(count_idx), 2)], get(cur_axes, 'YLim'), 'Color', [204, 102, 0]/255,...
        'LineStyle', '--');
    
    % ctrl grp
    line([ctrl_mu(rows(count_idx), cols(count_idx)), ctrl_mu(rows(count_idx), cols(count_idx))], get(cur_axes, 'YLim'), 'Color', [0, 0, 255]/255,...
        'LineStyle', '-', 'LineWidth', 1.2);
    line([ctrl_prctiles(rows(count_idx), cols(count_idx), 1), ctrl_prctiles(rows(count_idx), cols(count_idx), 1)], get(cur_axes, 'YLim'), 'Color', [0, 0, 255]/255,...
        'LineStyle', '--');
    line([ctrl_prctiles(rows(count_idx), cols(count_idx), 2), ctrl_prctiles(rows(count_idx), cols(count_idx), 2)], get(cur_axes, 'YLim'), 'Color', [0, 0, 255]/255,...
        'LineStyle', '--');
    
    line([0, 0], get(cur_axes, 'YLim'), 'Color', [0, 0, 0],...
        'LineStyle', ':');
    
    
end
suptitle(top_tit);
end

