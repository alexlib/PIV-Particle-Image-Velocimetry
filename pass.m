function pass(Storage,window_size,overlap,varargin)
%pass Рассчет векторного поля...
%   Выполняет...

% Определиние стандартных параметров
type_pass = 'first';
double_corr = false;
restriction = false;
deform = false;
borders = true;

k = 2;
while k <= size(varargin,2)
    switch varargin{k-1}
        case 'type_pass', type_pass = varargin{k};
        case 'double_corr'
            double_corr = true;
            direct = varargin{k};
        case 'restriction'
            restriction = true;
            restriction_area = varargin{k};
            switch restriction_area
                case '1/2', restriction_area = 1/2;
                case '1/3', restriction_area = 1/3;
                case '1/4', restriction_area = 1/4;
                otherwise, error('Недопустимый параметр');
            end
        case 'deform'
            deform = true;
            deform_type = varargin{k};
        case 'borders', borders = varargin{k};
        otherwise, error('Указан неправильный параметр');
    end
    k = k + 2;
end

% Проверка на изменение заданного размера и наложения окона опроса
if ~strcmp(type_pass,'first') && (~isequal(Storage.window_size,window_size) || ~isequal(Storage.overlap,overlap))
    multigrid = true;
else
    multigrid = false;
end

% Запись новых размеров
Storage.window_size = window_size;
Storage.overlap = overlap;

% Блок деформации изображения
if deform
    Storage.vectors_map_last_pass = imresize(Storage.vectors_map_last_pass,size(Storage.image_1),'bilinear');
    switch deform_type
        case 'central'
            Storage.image_1 = imwarp(Storage.image_1,-Storage.vectors_map_last_pass/2);
            Storage.image_2 = imwarp(Storage.image_2,Storage.vectors_map_last_pass/2);
        case 'second'
            Storage.image_2 = imwarp(Storage.image_2,Storage.vectors_map_last_pass);
        otherwise , error('Указан неизвестный метод');
    end
end

% Формирование координат окн опроса на первом изображении
if strcmp(type_pass,'first') || (multigrid)
    [X0,Y0] = images_split(Storage,window_size,overlap,borders);
else
    X0 = floor(Storage.centers_map(:,:,1))-ceil(window_size(2)/2) + 1;
    Y0 = floor(Storage.centers_map(:,:,2))-ceil(window_size(1)/2) + 1;
end

%*******************************
% Отладочная информация (Удалить)
Storage.temp_X0_1 = X0;
Storage.temp_Y0_1 = Y0;
Storage.temp_X0_2 = Storage.temp_X0_1;
Storage.temp_Y0_2 = Storage.temp_Y0_1;
Storage.temp_Xe_2 = Storage.temp_X0_1 + window_size(2) - 1;
Storage.temp_Ye_2 = Storage.temp_Y0_1 + window_size(1) - 1;
%*******************************

% Размер векторного поля
size_map = size(X0);

% Блок масштабирования векторного поля MultiGrid
if multigrid
    Storage.vectors_map = imresize(Storage.vectors_map,size_map,'nearest');
end

% Инициализация новых масок
Storage.outliers_map = zeros(size_map);
Storage.replaces_map = zeros(size_map);

Storage.correlation_maps = cell(size_map);
% Расчёт корреляционных карт
if strcmp(type_pass,'first') || (deform)
    % В случае отсутвия смещения окон опроса для второго изображения
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            cross_correlate(Storage,i,j,X0,Y0,double_corr);
        end
    end
else
    % Центр без границ
    for i = 2:size_map(1)-1
        for j = 2:size_map(2)-1
            cross_correlate(Storage,i,j,X0,Y0,double_corr,'offset','validate_borders');
        end
    end
    % Левая граница
    for i = 1:size_map(1), cross_correlate(Storage,i,1,X0,Y0,double_corr,'offset','validate_borders'); end
    % Правая граница
    for i = 1:size_map(1), cross_correlate(Storage,i,size_map(2),X0,Y0,double_corr,'offset','validate_borders'); end
    % Верхняя граница
    for j = 1:size_map(2), cross_correlate(Storage,1,j,X0,Y0,double_corr,'offset','validate_borders'); end
    % Нижняя граница
    for j = 1:size_map(2), cross_correlate(Storage,size_map(1),j,X0,Y0,double_corr,'offset','validate_borders'); end
end

% Различные методы перемножения соседних карт корреляции
if double_corr
    switch direct
        case 'x', direct_x(Storage); % Перемножение с правой корреляционной картой
        case 'y', direct_y(Storage); % Перемножение с нижней корреляционной картой
        case 'xy', direct_xy(Storage); % Перемножение с правой и нижней корреляционными картами
        case 'center', direct_center(Storage); % Перемножение с 4-мя соседними корреляционными картами
        otherwise, error('Неизвестный метод');
    end
end

% Поиск максимума коррляционного пика
if strcmp(type_pass,'first') || (deform)
    Storage.vectors_map_last_pass = zeros(size(Storage.centers_map));
end
if restriction % С ограничением
    x_start = window_size(2) - round(restriction_area*window_size(2));
    x_end = window_size(2) + round(restriction_area*window_size(2));
    y_start = window_size(1) - round(restriction_area*window_size(1));
    y_end = window_size(1) + round(restriction_area*window_size(1));
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
            [y_peak,x_peak] = find(limit_corr_map==max(limit_corr_map(:)));
            Storage.vectors_map_last_pass(i,j,:) = [x_peak(1) - window_size(2) + x_start - 1,y_peak(1) - window_size(1) + y_start - 1];
        end
    end
else % Без ограничения
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            [y_peak,x_peak] = find(Storage.correlation_maps{i,j}==max(Storage.correlation_maps{i,j}(:)));
            Storage.vectors_map_last_pass(i,j,:) = [x_peak(1) - window_size(2),y_peak(1) - window_size(1)];
        end
    end
end

% Запись результирующего векторного поля
if strcmp(type_pass,'first')
    Storage.vectors_map = Storage.vectors_map_last_pass;
else
    Storage.vectors_map = Storage.vectors_map + Storage.vectors_map_last_pass;
end

end

function cross_correlate(Storage,i,j,X0,Y0,double_corr,varargin)

validate_borders = false;
x_start = X0(i,j);
x_end = X0(i,j) + Storage.window_size(2)-1;
y_start = Y0(i,j);
y_end = Y0(i,j) + Storage.window_size(1)-1;

k = 1;
while k <= size(varargin,2)
    switch varargin{k}
        case 'offset'
            x_start = x_start + round(Storage.vectors_map(i,j,1));
            x_end = x_end + round(Storage.vectors_map(i,j,1));
            y_start = y_start + round(Storage.vectors_map(i,j,2));
            y_end = y_end + round(Storage.vectors_map(i,j,2));
        case 'validate_borders', validate_borders = true;
        otherwise, error('Указан неправильный параметр');
    end
    k = k + 1;
end

if validate_borders, [x_start,x_end,y_start,y_end] = validate(Storage,x_start,x_end,y_start,y_end); end
%*******************************
% Отладочная информация (Удалить)
Storage.temp_X0_2(i,j) = x_start;
Storage.temp_Y0_2(i,j) = y_start;
Storage.temp_Xe_2(i,j) = x_end;
Storage.temp_Ye_2(i,j) = x_end;
%*******************************
sliding_windows_2 = Storage.image_2(y_start:y_end,x_start:x_end);
sliding_windows_1 = Storage.image_1(Y0(i,j):Y0(i,j) + Storage.window_size(1)-1,X0(i,j):X0(i,j) + Storage.window_size(2)-1);

try
    Storage.correlation_maps{i,j} = normxcorr2(sliding_windows_1,sliding_windows_2);
catch ME
    if (strcmp(ME.identifier,'images:normxcorr2:sameElementsInTemplate'))
        if double_corr
            Storage.correlation_maps{i,j} = ones(2*Storage.window_size-1);
        else
            Storage.correlation_maps{i,j} = zeros(2*Storage.window_size-1);
        end
    else
        error(ME.identifier);
    end
end

end

function [x_start,x_end,y_start,y_end] = validate(Storage,x_start,x_end,y_start,y_end)

[H,W] = size(Storage.image_1);

if x_start < 1
    x_end = x_end + 1 - x_start;
    x_start = 1;
end
if x_end > W
    x_start = x_start - x_end + W;
    x_end = W;
end
if y_start < 1
    y_end = y_end + 1 - y_start;
    y_start = 1;
end
if y_end > H
    y_start = y_start - y_end + H;
    y_end = H;
end

end

function direct_x(Storage)

for i = 1:size(Storage.correlation_maps,1)
    for j = 1:size(Storage.correlation_maps,2)-1 % Для крайнего правого столбца перемножение не выполняется
        Storage.correlation_maps{i,j} = Storage.correlation_maps{i,j}.*Storage.correlation_maps{i,j+1};
    end
end

end

function direct_y(Storage)

for i = 1:size(Storage.correlation_maps,1)-1 % Для крайней нижней строки перемножение не выполняется
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