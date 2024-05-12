function [varargout] = validate_outliers(Storage,varargin)
%Функция проверки на выбросы методом нормализованной медианы
% Возможно проверить один конкретный вектор на выброс, а также задать свои
% параметры расчета

% Определиние стандартный параметров
r = 2; % Радиус окрестности центральной точки (обычно устанавливается равным 1 или 2)
threshold = 2; % Порог флуктуация (обычно около 2)
noise = 1.0; % Рассчитанный уровень шума при измерении (в пикселях)
borders = true; % Рассчитывать ли границы
single = false; % Расчет одного конкрентного вектора

% Запись переданных параметров
k = 2;
while k <= size(varargin,2)
    switch varargin{k-1}
        case 'radius'
            r = varargin{k};
        case 'threshold'
            threshold = varargin{k};
        case 'noise'
            noise = varargin{k};
        case 'borders'
            borders = varargin{k};
        case 'single'
            single = true;
            i_single = varargin{k}(1);
            j_single = varargin{k}(2);
        otherwise
            error('Указан неправильный параметр')
    end
    k = k + 2;
end

% Размер векторной карты
[H,W] = size(Storage.vectors_map,1:2);
% Нормализованного колебания относительно окрестности
NormFluct = zeros(H,W,2);
% Область с центральной точкой
Neigh = zeros(2*r+1,2*r+1);
% Перевод в столбец-вектор
NeighCol = Neigh(:);
% Окрестности, исключая центральную точку
NeighColEx = [NeighCol(1:(2*r+1)*r+r); NeighCol((2*r+1)*r+r+2:end)];

% Поиск выбросов или выброса для конкретной коодинаты
if single
    if (i_single<r+1)||(j_single<r+1)||(i_single>H-r)||((j_single>W-r))
        calculate_borders([i_single,j_single]);
    else
        calculate_outliers_without_borders(i_single,j_single);
    end
    varargout{1} = outliers_coordinates(i_single,j_single);
else
    Storage.outliers_map = zeros(H,W);
    calculate_outliers_without_borders(1+r:H-r,1+r:W-r);
    if borders
        calculate_borders;
    end
    outliers_coordinates;
end

function calculate_outliers_without_borders(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:i+r,j-r:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(2*r+1)*r+r); NeighCol((2*r+1)*r+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function calculate_median(i,j,c)
    Median = median(NeighColEx); % Медиана окрестности
    Fluct = Storage.vectors_map(i,j,c) - Median; % Колебания относительно медианы
    Res = NeighColEx - Median; % Остаточные колебания соседей относительно медианы
    MedianRes = median(abs(Res)); % Медианное (абсолютное) значение остатка
    NormFluct(i,j,c) = abs(Fluct/(MedianRes + noise)); % Нормализованного колебания относительно окрестности
end

function calculate_borders(varargin)

if isempty(varargin)
    % top
    top_median(1:r,1+r:W-r);
    % bottom
    bottom_median(H-r+1:H,1+r:W-r);
    % left
    left_median(1+r:H-r,1:r);
    % right
    right_median(1+r:H-r,W-r+1:W);
    % top-left
    top_left_median(1:r,1:r);
    % top-right
    top_right_median(1:r,W-r+1:W);
    % bottom-left
    bottom_left_median(H-r+1:H,1:r);
    % bottom-right
    bottom_right_median(H-r+1:H,W-r+1:W);
else
    i = varargin{1}(1);
    j = varargin{1}(2);
    if (i<r+1)&&(j>r)&&(j<=W-r)
        top_median(i,j);
    elseif (i>H-r)&&(j>r)&&(j<=W-r)
        bottom_median(i,j);
    elseif (j<r+1)&&(i>r)&&(i<=H-r)
        left_median(i,j);
    elseif (j>W-r)&&(i>r)&&(i<=H-r)
        right_median(i,j);
    elseif (i<r+1)&&(j<r+1)
        top_left_median(i,j);
    elseif (i<r+1)&&(j>W-r)
        top_right_median(i,j);
    elseif (i>H-r)&&(j<r+1)
        bottom_left_median(i,j);
    else
        bottom_right_median(i,j);
    end
end

end

function top_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(1:i+r,j-r:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+i)*r+i-1); NeighCol((r+i)*r+i+1:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function bottom_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:H,j-r:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+H-i+1)*r+r); NeighCol((r+H-i+1)*r+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function left_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:i+r,1:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(2*r+1)*(j-1)+r); NeighCol((2*r+1)*(j-1)+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function right_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:i+r,j-r:W,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(2*r+1)*r+r); NeighCol((2*r+1)*r+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function top_left_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(1:i+r,1:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+i)*(j-1)+i-1); NeighCol((r+i)*(j-1)+i+1:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function top_right_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(1:i+r,j-r:W,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+i)*r+i-1); NeighCol((r+i)*r+i+1:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function bottom_left_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:H,1:j+r,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+H-i+1)*(j-1)+r); NeighCol((r+H-i+1)*(j-1)+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function bottom_right_median(i_vec,j_vec)
    for c = 1:2
        for i = i_vec
            for j = j_vec
                Neigh = Storage.vectors_map(i-r:H,j-r:W,c);
                NeighCol = Neigh(:);
                NeighColEx = [NeighCol(1:(r+H-i+1)*r+r); NeighCol((r+H-i+1)*r+r+2:end)];
                calculate_median(i,j,c);
            end
        end
    end
end

function [varargout] = outliers_coordinates(varargin)
    
    if isempty(varargin)
        for i = 1:H
            for j = 1:W
                if (sqrt(NormFluct(i,j,1)^2 + NormFluct(i,j,2)^2)) > threshold
                    Storage.outliers_map(i,j) = 1;
                end
            end
        end
    else
        i = varargin{1};
        j = varargin{2};
        if (sqrt(NormFluct(i,j,1)^2 + NormFluct(i,j,2)^2)) > threshold
            varargout{1} = true;
        else
            varargout{1} = false;
        end
    end
end

end