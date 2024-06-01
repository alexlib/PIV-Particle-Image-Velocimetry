function interpolate_outliers(Storage,varargin)
%interpolate_outliers Замена выбросов медианным значение окрестности
%   Возможно задать размер окрестности

% Параметры по умолчанию
r = 2; % радиус окрестности

% Парсер заданных параметров
k = 2;
while k <= size(varargin,2)
    switch varargin{k-1}
        case 'radius'
            r = varargin{k};
        otherwise
            error('Указан неправильный параметр')
    end
    k = k + 2;
end

% Перевод маски выбросов в вектор координат
[H,W] = size(Storage.outliers_map);
outliers_vector = [];
number_outliers = 0;
for i = 1:H
    for j = 1:W
        if Storage.outliers_map(i,j)
            number_outliers = number_outliers + 1;
            outliers_vector(number_outliers,:) = [i,j];
        end
    end
end

% Интерполяция всех выбросов
while number_outliers > 0 % повторяем интерполяцию до тех пор, пока все вектора не пройдут проверку
    interpolate(Storage,outliers_vector,H,W,r);
    % Проверка интерполированных значений на выброс
    n = 1;
    while n <= number_outliers
        i = outliers_vector(n,1);
        j = outliers_vector(n,2);
        if validate_outliers(Storage,'single',[i,j]) % проверка на выброс после интерполяции
            % Если вектор остался выбросом после интерполяции
            n = n + 1;
        else % исключение из вектора координат успешно интерполированного выброса
            outliers_vector(n,:) = [];
            Storage.outliers_map(i,j) = 0;
            Storage.replaces_map(i,j) = 1;
            number_outliers = number_outliers - 1;
        end
    end
end

end

function interpolate(Storage,outliers_vector,H,W,r)

for n = 1:size(outliers_vector,1)
    i = outliers_vector(n,1);
    j = outliers_vector(n,2);
    if (i<r+1)||(j<r+1)||(i>H-r)||((j>W-r))
        interpolate_borders(i,j);
    else
        interpolate_without_borders(i,j);
    end
end

function interpolate_without_borders(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:i+r,j-r:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(2*r+1)*r+r); NeighCol((2*r+1)*r+r+2:end)];
        Storage.vectors_map(i,j,c) = median(NeighColEx);
    end
end

function interpolate_borders(i,j)
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

function top_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(1:i+r,j-r:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+i)*r+i-1); NeighCol((r+i)*r+i+1:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function bottom_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:H,j-r:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+H-i+1)*r+r); NeighCol((r+H-i+1)*r+r+2:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function left_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:i+r,1:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(2*r+1)*(j-1)+r); NeighCol((2*r+1)*(j-1)+r+2:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function right_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:i+r,j-r:W,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(2*r+1)*r+r); NeighCol((2*r+1)*r+r+2:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function top_left_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(1:i+r,1:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+i)*(j-1)+i-1); NeighCol((r+i)*(j-1)+i+1:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function top_right_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(1:i+r,j-r:W,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+i)*r+i-1); NeighCol((r+i)*r+i+1:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function bottom_left_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:H,1:j+r,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+H-i+1)*(j-1)+r); NeighCol((r+H-i+1)*(j-1)+r+2:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

function bottom_right_median(i,j)
    for c = 1:2
        Neigh = Storage.vectors_map(i-r:H,j-r:W,c);
        NeighCol = Neigh(:);
        NeighColEx = [NeighCol(1:(r+H-i+1)*r+r); NeighCol((r+H-i+1)*r+r+2:end)];
        Storage.vectors_map(i, j, c) = median(NeighColEx);
    end
end

end