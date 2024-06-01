function data = get_compared_group(Storage,folder_address,image_format,processing_vec)
%get_compared_group Сравнение заданного векторного поля с результатами обработок
%   Находит среднеквадратическое модуля отклонения двух полей и максимум отклонения 

% Чтение адресов flow файлов и изображений из каталога
flow_files = dir(fullfile(folder_address, '*.flo'));
image_files = dir(fullfile(folder_address, image_format));

% Число flow файлов
N = size(flow_files,1);
% Число сценариев
P = size(processing_vec,1);
% Инициализация выходных данных
data = zeros(N,P,2);

for n = 1:N
    % Загрузка изображений
    image_address_1 = strcat(folder_address,'/',image_files(2*n-1).name);
    image_address_2 = strcat(folder_address,'/',image_files(2*n).name);
    load_images(Storage,image_address_1,image_address_2);
    
    % Загрузка исходного (сравниваемого) поля
    flow_address = strcat(folder_address,'/',flow_files(n).name);
    read_flow_file(Storage,flow_address);
    true_map = Storage.vectors_map;
    
    % Запуск сценариев и сравнение полей
    for p = 1:P
        % Запуск сценария
        processing_vec{p}(Storage);
        result_map = Storage.vectors_map;
        
        % Расчет матрицы отклонений по модулю
        [H,W,B] = size(result_map);
        div_map = zeros(H,W,B);
        for i = 1:H
            for j = 1:W
                for c = 1:2
                   div_map(i,j,c) = abs(result_map(i,j,c) - true_map(Storage.centers_map(i,j,2),Storage.centers_map(i,j,1),c));
                end
            end
        end
        
        % Расчет среднеквадратическое отклонения и максимума отклонения
        div_map_square = div_map(:,:,1).^2 + div_map(:,:,2).^2;
        div_RMS = sqrt(sum(div_map_square,'all')/(H*W*(H*W-1)));
        div_max = sqrt(max(div_map_square,[],'all'));
        
        % Запись результатов
        data(n,p,1) = div_RMS;
        data(n,p,2) = div_max;
    end
end

end
