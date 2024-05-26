function cross_correlate(Storage,size_map,X0,Y0,type_pass,deform,double_corr)

% Инициализация новых масок
Storage.outliers_map = zeros(size_map);
Storage.replaces_map = zeros(size_map);

% Инициализаци новых корреляционных карт
Storage.correlation_maps = cell(size_map);

if strcmp(type_pass,'first') || (deform) % В случае отсутвия смещения окон опроса для второго изображения
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            correlate(Storage,i,j,X0,Y0,double_corr);
        end
    end
else % Центр без границ
    for i = 2:size_map(1)-1
        for j = 2:size_map(2)-1
            correlate(Storage,i,j,X0,Y0,double_corr,'offset','validate_borders');
        end
    end
    % Левая граница
    for i = 1:size_map(1), correlate(Storage,i,1,X0,Y0,double_corr,'offset','validate_borders'); end
    % Правая граница
    for i = 1:size_map(1), correlate(Storage,i,size_map(2),X0,Y0,double_corr,'offset','validate_borders'); end
    % Верхняя граница
    for j = 1:size_map(2), correlate(Storage,1,j,X0,Y0,double_corr,'offset','validate_borders'); end
    % Нижняя граница
    for j = 1:size_map(2), correlate(Storage,size_map(1),j,X0,Y0,double_corr,'offset','validate_borders'); end
end

end


function correlate(Storage,i,j,X0,Y0,double_corr,varargin)
%cross_correlate Кросскорреляция окн опроса
%   Для кросскорреляции используется встроенная функция normxcorr2

% Опредление параметров по умолчанию
validate_borders = false;
x_start = X0(i,j);
x_end = X0(i,j) + Storage.window_size(2)-1;
y_start = Y0(i,j);
y_end = Y0(i,j) + Storage.window_size(1)-1;

% Парсер заданных параметов
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

sliding_windows_2 = Storage.image_2(y_start:y_end,x_start:x_end);
sliding_windows_1 = Storage.image_1(Y0(i,j):Y0(i,j) + Storage.window_size(1)-1,X0(i,j):X0(i,j) + Storage.window_size(2)-1);
try
    Storage.correlation_maps{i,j} = normxcorr2(sliding_windows_1,sliding_windows_2);
catch ME
    if (strcmp(ME.identifier,'images:normxcorr2:sameElementsInTemplate')) % в случае однородности окна опроса
        if double_corr
            Storage.correlation_maps{i,j} = ones(2*Storage.window_size-1);
        else
            Storage.correlation_maps{i,j} = zeros(2*Storage.window_size-1);
        end
        Storage.outliers_map(i,j) = 1; % запись в выбросы для особого поиска корреляционного пика
    else
        error(ME.identifier);
    end
end

end

function [x_start,x_end,y_start,y_end] = validate(Storage,x_start,x_end,y_start,y_end)
%validate Корректировка положения окон опроса в случае выхода за границы изобажения
%   Если окно опроса выходит за изображение, то сдвигаем внутрь изображения

[H,W] = size(Storage.image_1);

if x_start < 1,  x_end   = x_end + 1 - x_start;    x_start = 1;  end
if x_end   > W,  x_start = x_start   - x_end + W;  x_end   = W;  end
if y_start < 1,  y_end   = y_end + 1 - y_start;    y_start = 1;  end
if y_end   > H,  y_start = y_start   - y_end + H;  y_end   = H;  end

end