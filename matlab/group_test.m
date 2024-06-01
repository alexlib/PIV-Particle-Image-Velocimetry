% Скрипт тестирования группы сценариев обработка на наборе данных

% Очистка и инициализации класса хранения данных обработки
clear Storage
Storage = Storage();

% Определение каталога с данными и формата изображения
folder_address = 'demos/group_test';
image_format = '*.tif';

% Определение набора сценариев для расчета
processing_vec{1,1} = @processing_1;
processing_vec{2,1} = @processing_2;
processing_vec{3,1} = @processing_3;
processing_vec{4,1} = @processing_4;
processing_vec{5,1} = @processing_5;

% Сравнение векторных полей из flow файлов с результатами сценариев обработки
data = get_compared_group(Storage,folder_address,image_format,processing_vec);

% Визуализация результатов сравнения для всех сценариев
build_graphs_group(data);
