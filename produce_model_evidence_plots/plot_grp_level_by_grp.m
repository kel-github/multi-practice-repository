function [] = plot_grp_level_by_grp(idx, pos_idx, train_post, train_mu, train_prctiles, ctrl_post, ctrl_mu, ctrl_prctiles, x_range, colours, face_alpha, sig_group)


rows = [1 1 1; ...
        2 2 2; ...
        3 3 3];
cols = [1 2 3; ...
        1 2 3; ...
        1 2 3];

for count_idx = 1:length(idx)
    
    subplot('position', pos_idx(:,count_idx)')
    histogram(ctrl_post(rows(idx(count_idx)), cols(idx(count_idx)), :),  'Normalization', 'probability', ...
        'FaceColor', colours(2,:,count_idx)/255, 'EdgeColor', 'none');
    alpha(gca, face_alpha);
    hold on
    histogram(train_post(rows(idx(count_idx)), cols(idx(count_idx)), :), 'Normalization', 'probability', ...
        'FaceColor', colours(1,:, count_idx)/255, 'EdgeColor', 'none');
    alpha(gca, face_alpha);

    ylim([0, 0.1]);
    xlim(x_range);    
    ylabel('');
    xlabel('');
    if count_idx ~= 1
        set(gca,'xticklabel',{[]}, 'yticklabel',{[]});
    end    
    
%     %%%%%%%% now add mu's and CIs
%         % add mu and CIs
    cur_axes = gca;
%     % train grp
%     line([train_mu(rows(idx(count_idx)), cols(idx(count_idx))), train_mu(rows(idx(count_idx)), cols(idx(count_idx)))], get(cur_axes, 'YLim'), 'Color', colours(1,:)/255,...
%         'LineStyle', '-', 'LineWidth', 1.2);
    line([train_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1), train_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1)], get(cur_axes, 'YLim'), 'Color', colours(1,:, count_idx)/255,...
        'LineStyle', '-', 'LineWidth', 1);
    line([train_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2), train_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2)], get(cur_axes, 'YLim'), 'Color', colours(1,:, count_idx)/255,...
        'LineStyle', '-', 'LineWidth', 1);
%     
%     % ctrl grp
%     line([ctrl_mu(rows(idx(count_idx)), cols(idx(count_idx))), ctrl_mu(rows(idx(count_idx)), cols(idx(count_idx)))], get(cur_axes, 'YLim'), 'Color', colours(2,:)/255,...
%         'LineStyle', '-', 'LineWidth', 1.2);
    line([ctrl_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1), ctrl_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 1)], get(cur_axes, 'YLim'), 'Color', colours(2,:, count_idx)/255,...
        'LineStyle', '-', 'LineWidth', 1);
    line([ctrl_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2), ctrl_prctiles(rows(idx(count_idx)), cols(idx(count_idx)), 2)], get(cur_axes, 'YLim'), 'Color', colours(2,:, count_idx)/255,...
        'LineStyle', '-', 'LineWidth', 1);
    
    line([0, 0], get(cur_axes, 'YLim'), 'Color', [0, 0, 0],...
        'LineStyle', ':');
    
    if any(sig_group(count_idx))
        
      text(-0.5, .08, '*', 'FontSize', 14);  
    end
    
    box off   
end

end

