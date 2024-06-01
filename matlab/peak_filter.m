function [varargout] = peak_filter(Storage,varargin)
%peak_filter Проверка на выбросы по величине корреляционного пика
%   Возможно проверить один конкретный вектор на выброс, а также задать
%   свой порог фильтрации

% Определение параметров по умолчанию
threshold = 0.8; % порог фильтрации
single = false;  % проверить отдельный вектор

% Парсер заданных параметров
k = 2;
while k <= size(varargin,2)
    switch varargin{k-1}
        case 'threshold'
            threshold = varargin{k};
        case 'single'
            single = true;
            i_single = varargin{k}(1);
            j_single = varargin{k}(2);
        otherwise
            error('Указан неправильный параметр')
    end
    k = k + 2;
end

% Проверка на выброс
if single % одиночного вектора
    x_peak = Storage.vectors_map_last_pass(i_single,j_single,1) + Storage.window_size(2);
    y_peak = Storage.vectors_map_last_pass(i_single,j_single,2) + Storage.window_size(1);
    if Storage.correlation_maps{i_single,j_single}(y_peak,x_peak) < threshold
        varargout{1} = true;
    else
        varargout{1} = false;
    end
else % всех векторов
    for i = 1:size(Storage.vectors_map_last_pass,1)
        for j = 1:size(Storage.vectors_map_last_pass,2)
            x_peak = Storage.vectors_map_last_pass(i,j,1) + Storage.window_size(2);
            y_peak = Storage.vectors_map_last_pass(i,j,2) + Storage.window_size(1);
            if Storage.correlation_maps{i,j}(y_peak,x_peak) < threshold
                Storage.outliers_map(i,j) = 1;
            end
        end
    end
end

end