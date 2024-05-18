function replace_outliers_next_peak(Storage,varargin)
%replace_outliers_next_peak Замена выбросов 2 или 3 корреляционным пиком
%   Возможно задать ограничение поиска корреляционного пика

% Определиние параметров по умолчанию
restriction = false;

% Парсер заданных параметов
k = 2;
while k <= size(varargin,2)
    switch varargin{k-1}
        case 'restriction'
            restriction = true;
            restriction_area = varargin{k};
            switch restriction_area
                case '1/2', restriction_area = 1/2;
                case '1/3', restriction_area = 1/3;
                case '1/4', restriction_area = 1/4;
                otherwise, error('Недопустимый параметр');
            end
        otherwise, error('Указан неправильный параметр');
    end
    k = k + 2;
end

% Определение координат поиска корреляционного пика
if restriction % при ограничении 
    x_start = Storage.window_size(2) - round(restriction_area*Storage.window_size(2));
    x_end = Storage.window_size(2) + round(restriction_area*Storage.window_size(2));
    y_start = Storage.window_size(1) - round(restriction_area*Storage.window_size(1));
    y_end = Storage.window_size(1) + round(restriction_area*Storage.window_size(1));
else
    x_start = 1;
    x_end = 2*Storage.window_size(2) - 1;
    y_start = 1;
    y_end = 2*Storage.window_size(1) - 1;
end

% Перевод маски выбросов Storage.outliers_map в вектор координат
[H,W] = size(Storage.outliers_map);
outliers_vector = [];
number_outliers = 0;
for i = 1:H
    for j = W
        if Storage.outliers_map(i,j)
            number_outliers = number_outliers + 1;
            outliers_vector(number_outliers,:) = [i,j];
        end
    end
end

% Инициализация векторов координат и величин корреляционных пиков
x_peak_1 = zeros(number_outliers,1);
y_peak_1 = zeros(number_outliers,1);
value_peak_1 = zeros(number_outliers,1);

x_peak_2 = zeros(number_outliers,1);
y_peak_2 = zeros(number_outliers,1);
value_peak_2 = zeros(number_outliers,1);

x_peak_3 = zeros(number_outliers,1);
y_peak_3 = zeros(number_outliers,1);

% Замена выбросов вторым корреляционным пиком
for n = 1:number_outliers
    i = outliers_vector(n,1);
    j = outliers_vector(n,2);

    Storage.vectors_map(i,j,:) = Storage.vectors_map(i,j,:) - Storage.vectors_map_last_pass(i,j,:);
    
    % Запоминаем координаты и величину первого корреляционного пика и зануляем его
    x_peak_1(n) = Storage.vectors_map_last_pass(i,j,1) + Storage.window_size(2);
    y_peak_1(n) = Storage.vectors_map_last_pass(i,j,2) + Storage.window_size(1);
    value_peak_1(n) = Storage.correlation_maps{i,j}(y_peak_1(n),x_peak_1(n));
    Storage.correlation_maps{i,j}(y_peak_1(n),x_peak_1(n)) = 0;
    
    % Находим второй корреляционный пик
    limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
    [y_peak,x_peak] = find(limit_corr_map==max(limit_corr_map(:)));
    x_peak_2(n) = x_peak(1) - Storage.window_size(2) + x_start - 1;
    y_peak_2(n) = y_peak(1) - Storage.window_size(1) + y_start - 1;
    Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) + [x_peak_2(n);y_peak_2(n)];
end

% Проверка на выброс и замена третьим корреляционным пиком
for n = 1:number_outliers
    i = outliers_vector(n,1);
    j = outliers_vector(n,2);

    if validate_outliers(Storage,'single',[i,j])
        Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) - [x_peak_2(n);y_peak_2(n)];
        
        value_peak_2(n) = Storage.correlation_maps{i,j}(y_peak_2(n) + Storage.window_size(1),x_peak_2(n) + Storage.window_size(2));
        Storage.correlation_maps{i,j}(y_peak_2(n) + Storage.window_size(1),x_peak_2(n) + Storage.window_size(2)) = 0;
        
        % Находим третий корреляционный пик
        limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
        [y_peak,x_peak] = find(limit_corr_map==max(limit_corr_map(:)));
        x_peak_3(n) = x_peak(1) - Storage.window_size(2) + x_start - 1;
        y_peak_3(n) = y_peak(1) - Storage.window_size(1) + y_start - 1;
        Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) + [x_peak_3(n);y_peak_3(n)];
    else
        Storage.vectors_map_last_pass(i,j,:) = [x_peak_2(n),y_peak_2(n)];
        Storage.outliers_map(i,j) = 0;
        Storage.replaces_map(i,j) = 2;
    end
end

% Проверка на выброс и возвращение исходных значений
for n = 1:number_outliers
    i = outliers_vector(n,1);
    j = outliers_vector(n,2);

    if Storage.replaces_map(i,j) ~= 2
        if validate_outliers(Storage,'single',[i,j])
            Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) - [x_peak_3(n);y_peak_3(n)];
            
            % Возвращаем исходные значения векторной карты и корреляционных пиков
            Storage.vectors_map(i,j,:) = Storage.vectors_map(i,j,:) + Storage.vectors_map_last_pass(i,j,:);
            Storage.correlation_maps{i,j}(y_peak_1(n) + Storage.window_size(1),x_peak_1(n) + Storage.window_size(2)) = value_peak_1(n);
            Storage.correlation_maps{i,j}(y_peak_2(n) + Storage.window_size(1),x_peak_2(n) + Storage.window_size(2)) = value_peak_2(n);
        else
            Storage.vectors_map_last_pass(i,j,:) = [x_peak_3(n),y_peak_3(n)];
            Storage.outliers_map(i,j) = 0;
            Storage.replaces_map(i,j) = 3;
        end
    end
end

end