function double_correlate(Storage,direct)

switch direct
    case 'x', direct_x(Storage); % Перемножение с правой корреляционной картой
    case 'y', direct_y(Storage); % Перемножение с нижней корреляционной картой
    case 'xy', direct_xy(Storage); % Перемножение с правой и нижней корреляционными картами
    case 'center', direct_center(Storage); % Перемножение с 4-мя соседними корреляционными картами
    otherwise, error('Неизвестный метод');
end

end

function direct_x(Storage)
% Для крайнего правого столбца перемножение не выполняется
for i = 1:size(Storage.correlation_maps,1)
    for j = 1:size(Storage.correlation_maps,2)-1
        Storage.correlation_maps{i,j} = Storage.correlation_maps{i,j}.*Storage.correlation_maps{i,j+1};
    end
end

end

function direct_y(Storage)
% Для крайней нижней строки перемножение не выполняется
for i = 1:size(Storage.correlation_maps,1)-1
    for j = 1:size(Storage.correlation_maps,2)
        Storage.correlation_maps{i,j} = Storage.correlation_maps{i,j}.*Storage.correlation_maps{i+1,j};
    end
end

end

function direct_xy(Storage)
% Для крайних правого столбца и нижней строки перемножение не выполняется
for i = 1:size(Storage.correlation_maps,1)-1
    for j = 1:size(Storage.correlation_maps,2)-1
        Storage.correlation_maps{i,j} = Storage.correlation_maps{i,j}.*Storage.correlation_maps{i+1,j}.*Storage.correlation_maps{i,j+1};
    end
end

end

function direct_center(Storage)

% Запоминаем начальное состояние предыдущей левой корреляционной карты
corr_map_prev_left = Storage.correlation_maps{2,1};
% Запоминаем начальные состояния предыдущих верхних корреляционных карт
corr_maps_prev_top = cell(size(Storage.correlation_maps,2)-2,1);
for j = 1:size(Storage.correlation_maps,2)-2
    corr_maps_prev_top{j} = Storage.correlation_maps{1,j+1};
end

% Для граничных корреляционных карт перемножение не выполняется
for i = 2:size(Storage.correlation_maps,1)-1
    for j = 2:size(Storage.correlation_maps,2)-1
        corr_map_right = Storage.correlation_maps{i,j+1};
        corr_map_bottom = Storage.correlation_maps{i+1,j};
        
        corr_map_left = corr_map_prev_left;
        corr_map_top = corr_maps_prev_top{j-1};
        
        corr_map_prev_left = Storage.correlation_maps{i,j};
        corr_maps_prev_top{j-1} = corr_map_prev_left;

        Storage.correlation_maps{i,j} = Storage.correlation_maps{i,j}.*corr_map_right.*corr_map_bottom.*corr_map_left.*corr_map_top;
    end
end

end