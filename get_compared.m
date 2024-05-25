function div_vec = get_compared(Storage,procedure,image_address_1,image_address_2,visual_map,visual_bar,varargin)

if isempty(varargin), error('Не заполнены парамтеры'); end

flow = false;
compare = false;
mean_target = 0;
max_target = 0;

k = 1;
switch varargin{k}
    case 'flow'
        flow = true;
        k = k + 1;
        flow_address = varargin{k};
    case 'custom'
        k = k + 1;
        vectors_map = varargin{k};
    otherwise, error('Неправильный параметр');
end

if size(varargin,2) > k
    compare = true;
    k = k + 1;
    mean_target = varargin{k};
end

if size(varargin,2) > k
    max_target = varargin{k+1};
end

% Загрузка изображений
load_images(Storage,image_address_1,image_address_2);

% Предобработка изображений
preprocessing(Storage)

% Загрузка истинного поля
if flow
    read_flow_file(Storage,flow_address);
    true_map = Storage.vectors_map;
end

% Запуск заданного сценария
procedure(Storage);
result_map = Storage.vectors_map;

% Визуализация
if visual_map, show(Storage); pause on; pause; end

% Расчет матрицы отклонений по модулю
if flow % в сравнении с полем из файла flow
    [H,W,B] = size(result_map);
    div_map = zeros(H,W,B);
    for i = 1:H
        for j = 1:W
            for c = 1:2
               div_map(i,j,c) = abs(result_map(i,j,c) - true_map(Storage.centers_map(i,j,2),Storage.centers_map(i,j,1),c));
            end
        end
    end
else % в сравнении с полем с указанными координатами вектором (центров)
    if ~isequal(size(vectors_map),size(result_map)), error('Не соотвествие размеров'); end
    [H,W,B] = size(vectors_map);
    div_map = zeros(H,W,B);
    for i = 1:H
        for j = 1:W
            for c = 1:2
               div_map(i,j,c) = abs(result_map(i,j,c) - vectors_map(i,j,c));
            end
        end
    end
end

% Расчет среднего арефметического отклонения и максимума отклонения
div_mean = sum(div_map,'all')/(H*W*B);
div_max = max(div_map,[],'all');

% Запись результатов
div_vec = [div_mean;div_max];

% Визуализация результатов
if visual_bar
    if compare
        get_graph([div_vec(1) div_vec(2);mean_target max_target]);
    else
        get_graph([div_vec(1) div_vec(2)]);
    end
end

end

function get_graph(bar_values)

b = bar(bar_values,'grouped','FaceColor','flat');

xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom');

if size(bar_values,1) > 1
    xtips2 = b(2).XEndPoints;
    ytips2 = b(2).YEndPoints;
    labels2 = string(b(2).YData);
    text(xtips2,ytips2,labels2,'HorizontalAlignment','center','VerticalAlignment','bottom');

    b(2).CData(1,:) = [0.85 0.325 0.098];
    b(2).CData(2,:) = b(2).CData(1,:);
else
    b.CData(2,:) = [0.85 0.325 0.098];
end

pause on; pause;

end