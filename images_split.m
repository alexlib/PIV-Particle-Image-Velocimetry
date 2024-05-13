function [X0,Y0] = images_split(Storage,window_size,overlap,borders)
%images_split Рассчет координат окон опроса на изображении
%   Выполняет расчет координат окон опроса без учета векторного поля

% Размер изображения
image_size = size(Storage.image_1);

% Количество окон опроса по горизонтали и вертикали
field_shape = floor((image_size - window_size)./(window_size - overlap)) + 1;

% Размер области покрытия изображения окнами опроса
w = field_shape(2)*(window_size(2) - overlap(2))+overlap(2);
h = field_shape(1)*(window_size(1) - overlap(1))+overlap(1);

% Остаточные границы не покрытых окнами опроса
remainder = [image_size(1) - h, image_size(2) - w];

% Остаточные границы в левой верхней части изображения
x_left_remainder = floor(remainder(2)/2)+1;
y_top_remainder = floor(remainder(1)/2)+1;

% Размер центрированной области покрытия окнами опроса изображения
search_area_size = [x_left_remainder, y_top_remainder, w, h];

% Вычисление центров оконо опроса
if (window_size(2) - overlap(2)) > 1 % Для наложения больше одного пикселя
    x = (search_area_size(1)+ceil(window_size(2)/2) - 1):(window_size(2) - overlap(2)):(search_area_size(1)+search_area_size(3)-ceil(window_size(2)/2));
    y = (search_area_size(2)+ceil(window_size(1)/2) - 1):(window_size(1) - overlap(1)):(search_area_size(2)+search_area_size(4)-ceil(window_size(1)/2));
else                                 % Для наложения равного одному пикселю
    x = (search_area_size(1)+ceil(window_size(2)/2) - 1):(window_size(2) - overlap(2)):(search_area_size(1)+search_area_size(3)-ceil(window_size(2)/2) - 1);
    y = (search_area_size(2)+ceil(window_size(1)/2) - 1):(window_size(1) - overlap(1)):(search_area_size(2)+search_area_size(4)-ceil(window_size(1)/2) - 1);
end

% Добавление окон опроса на границах изображения для полного покрытия изображения
if borders
    if remainder(1) ~= 0
        if remainder(1) == 1 % Если остаточная граница равна одному пикселю
            y = [y(:);y(end) + floor(remainder(1)/2) + mod(remainder(1),2)];
        else
            y = [y(1) - floor(remainder(1)/2);y(:);y(end) + floor(remainder(1)/2) + mod(remainder(1),2)];
        end
    end
    if remainder(2) ~= 0
        if remainder(2) == 1
            x = [x(:);x(end) + floor(remainder(2)/2) + mod(remainder(2),2)];
        else
            x = [x(1) - floor(remainder(2)/2);x(:);x(end) + floor(remainder(2)/2) + mod(remainder(2),2)];
        end
    end
end

% % Поправка центров для четных размеров окон опроса (вероятно не нужна)
% if mod(window_size(2),2) == 0
%     x = x + 0.5;
% end
% if mod(window_size(1),2) == 0
%     y = y + 0.5;
% end

% Опредление матриц координат центров окон опроса
[X,Y] = meshgrid(x,y);

% Запись центров окон опроса
Storage.centers_map = zeros([size(X),2]);
Storage.centers_map(:,:,1) = X;
Storage.centers_map(:,:,2) = Y;

% Запись начальных координат окн опроса, начало которых находится в левом
% верхнем углу окна
X0 = floor(X)-ceil(window_size(2)/2) + 1;
Y0 = floor(Y)-ceil(window_size(1)/2) + 1;

end