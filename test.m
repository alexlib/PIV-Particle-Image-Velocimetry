function vec = test(Storage,procedure,image_address_1,image_address_2,flow_address)

% Загрузка и предобработка изображений
load_images(Storage,image_address_1,image_address_2);
preprocessing(Storage)

% Загрузка истинного поля
read_flow_file(Storage,flow_address);
true_map = Storage.vectors_map;

% Запуск заданного сценария
procedure(Storage);

% Сравнение не полном разрешении
result = Storage.vectors_map;
[H,W,B] = size(result);

div = zeros(H,W,B);
for i = 1:H
    for j = 1:W
        for c = 1:2
           div(i,j,c) = abs(result(i,j,c) - true_map(Storage.centers_map(i,j,2),Storage.centers_map(i,j,1),c));
        end
    end
end

max_div = max(div,[],'all');
mean_div = sum(div,'all')/(H*W*B);

% Сравнение в полном разрешении
result = imresize(result,size(Storage.image_1),'bilinear');

[H,W,B] = size(result);
div_full = abs(result-true_map);

max_div_full = max(div_full,[],'all');
mean_div_full = sum(div_full,'all')/(H*W*B);

% Вывод результатов
vec = [mean_div;max_div;mean_div_full;max_div_full];

end