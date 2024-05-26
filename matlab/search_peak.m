function search_peak(Storage,size_map,restriction,restriction_area)

% Инициализация нового векторного поля последнего прохода
Storage.vectors_map_last_pass = zeros([size_map,2]);

if restriction % С ограничением
    x_start = Storage.window_size(2) - round(restriction_area*Storage.window_size(2));
    x_end = Storage.window_size(2) + round(restriction_area*Storage.window_size(2));
    y_start = Storage.window_size(1) - round(restriction_area*Storage.window_size(1));
    y_end = Storage.window_size(1) + round(restriction_area*Storage.window_size(1));
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            if Storage.outliers_map(i,j)
                Storage.vectors_map_last_pass(i,j,:) = [0,0];
                Storage.outliers_map(i,j) = 0;
            else
                limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
                [y_peak,x_peak] = find(limit_corr_map==max(limit_corr_map(:)));
                Storage.vectors_map_last_pass(i,j,:) = [x_peak(1) - Storage.window_size(2) + x_start - 1,y_peak(1) - Storage.window_size(1) + y_start - 1];
            end
        end
    end
else % Без ограничения
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            if Storage.outliers_map(i,j)
                Storage.vectors_map_last_pass(i,j,:) = [0,0];
                Storage.outliers_map(i,j) = 0;
            else
                [y_peak,x_peak] = find(Storage.correlation_maps{i,j}==max(Storage.correlation_maps{i,j}(:)));
                Storage.vectors_map_last_pass(i,j,:) = [x_peak(1) - Storage.window_size(2),y_peak(1) - Storage.window_size(1)];
            end
        end
    end
end

end