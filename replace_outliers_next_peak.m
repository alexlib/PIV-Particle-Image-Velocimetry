function replace_outliers_next_peak(Storage,varargin)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% Определиние стандартных параметров
restriction = false;

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

% Определение величины ограничения поиска корреляционного пика
if restriction
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

for n = 1:number_outliers
    i = outliers_vector(n,1);
    j = outliers_vector(n,2);

    Storage.vectors_map(i,j,:) = Storage.vectors_map(i,j,:) - Storage.vectors_map_last_pass(i,j,:);

    x_peak_1 = Storage.vectors_map_last_pass(i,j,1) + Storage.window_size(2);
    y_peak_1 = Storage.vectors_map_last_pass(i,j,2) + Storage.window_size(1);
    
    value_peak_1 = Storage.correlation_maps{i,j}(y_peak_1,x_peak_1);
    Storage.correlation_maps{i,j}(y_peak_1,x_peak_1) = 0;

    limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
    [y_peak_2,x_peak_2] = find(limit_corr_map==max(limit_corr_map(:)));
    x_peak_2 = x_peak_2(1) - Storage.window_size(2) + x_start - 1;
    y_peak_2 = y_peak_2(1) - Storage.window_size(1) + y_start - 1;
    Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) + [x_peak_2;y_peak_2];
    if validate_outliers(Storage,'single',[i,j])
        Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) - [x_peak_2;y_peak_2];
        
        value_peak_2 = Storage.correlation_maps{i,j}(y_peak_2 + Storage.window_size(1),x_peak_2 + Storage.window_size(2));
        Storage.correlation_maps{i,j}(y_peak_2 + Storage.window_size(1),x_peak_2 + Storage.window_size(2)) = 0;

        limit_corr_map = Storage.correlation_maps{i,j}(y_start:y_end,x_start:x_end);
        [y_peak_3,x_peak_3] = find(limit_corr_map==max(limit_corr_map(:)));
        x_peak_3 = x_peak_3(1) - Storage.window_size(2) + x_start - 1;
        y_peak_3 = y_peak_3(1) - Storage.window_size(1) + y_start - 1;
        Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) + [x_peak_3;y_peak_3];
        if validate_outliers(Storage,'single',[i,j])
            Storage.vectors_map(i,j,:) = squeeze(Storage.vectors_map(i,j,:)) - [x_peak_3;y_peak_3];

            Storage.vectors_map(i,j,:) = Storage.vectors_map(i,j,:) + Storage.vectors_map_last_pass(i,j,:);
            
            Storage.correlation_maps{i,j}(y_peak_1 + Storage.window_size(1),x_peak_1 + Storage.window_size(2)) = value_peak_1;
            Storage.correlation_maps{i,j}(y_peak_2 + Storage.window_size(1),x_peak_2 + Storage.window_size(2)) = value_peak_2;
        else
            Storage.vectors_map_last_pass(i,j,:) = [x_peak_3,y_peak_3];
            Storage.outliers_map(i,j) = 0;
            Storage.replaces_map(i,j) = 3;
        end
    else
        Storage.vectors_map_last_pass(i,j,:) = [x_peak_2,y_peak_2];
        Storage.outliers_map(i,j) = 0;
        Storage.replaces_map(i,j) = 2;
    end
end

end