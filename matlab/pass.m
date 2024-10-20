function pass(Storage,window_size,overlap,varargin)
%pass Расчет векторного поля кросскорреляционным методом
%   Выполняет кросскорреляцию локальных областей (окн опроса) на паре
%   изображений. В зависимости от заданных параметров может работать, как
%   проход для получения первичного векторного поля, так и проход для
%   уточнения существующего векторного поля.

%--------------------------------------------------------------------------
% Определение параметров по умолчанию
type_pass = 'first';       % тип прохода 'first' или 'next'
double_corr = false;       % перемножение соседних корреляционных карт
direct = 'x';              % метод перемножение
restriction = false;       % ограничение области поиска корреляционного пика
restriction_area = '1/2';  % величина ограничения от размера окна
deform = false;            % деформация изображений
deform_type = 'symmetric'; % тип деформации
borders = true;            % обработка границ изображений
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Парсер заданных параметров
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
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Проверка на изменение размера и величины наложения окон опроса
multigrid = ~strcmp(type_pass,'first') && (~isequal(Storage.window_size,window_size) || ~isequal(Storage.overlap,overlap));

% Запись новых размеров и величины наложения окон опроса
Storage.window_size = window_size;
Storage.overlap = overlap;
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Формирование координат окн опроса на первом изображении
[X0,Y0] = images_split(Storage,type_pass,multigrid,borders);

% Размер нового векторного поля
size_map = size(X0);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Деформации изображений
if deform, deform_images(Storage,deform_type); end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Масштабирование векторного поля (multigrid)
if multigrid, resize_field(Storage,size_map); end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Расчет корреляционных карт
cross_correlate(Storage,size_map,X0,Y0,type_pass,deform,double_corr);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Перемножение соседних карт корреляции
if double_corr, double_correlate(Storage,direct); end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Поиск максимума корреляционного пика
search_peak(Storage,size_map,restriction,restriction_area);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Запись результирующего векторного поля
if strcmp(type_pass,'first'), Storage.vectors_map = Storage.vectors_map_last_pass;
else, Storage.vectors_map = Storage.vectors_map + Storage.vectors_map_last_pass; end
%--------------------------------------------------------------------------

end
