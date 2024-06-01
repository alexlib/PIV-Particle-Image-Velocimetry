% Скрипт тестирования заданного сценария обработки на 5-ти парах
% изображений с различными видами потока

%--------------------------------------------------------------------------
% Сценарий проверки
processing = @processing_1;

% Название сценария
name = 'single pass fast processing';
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок очистки и инициализации класса хранения данных обработки
clear Storage
Storage = Storage();
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок первой проверки
image_address_1 = 'demos/uniform_00001_img1.tif';
image_address_2 = 'demos/uniform_00001_img2.tif';
flow_address = 'demos/uniform_00001_flow.flo';
% vectors_map = load('vectors_map.mat');
visual_map = false; visual_bar = false;
mean_target = 0.0161; max_target = 0.1351;

div_vec_1 = get_compared(Storage,processing,image_address_1,image_address_2, ...
    visual_map,visual_bar,'flow',flow_address,mean_target,max_target);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок второй проверки
image_address_1 = 'demos/JHTDB_channel_00176_img1.tif';
image_address_2 = 'demos/JHTDB_channel_00176_img2.tif';
flow_address = 'demos/JHTDB_channel_00176_flow.flo';
% vectors_map = load('vectors_map.mat');
visual_map = false; visual_bar = false;
mean_target = 0.0866; max_target = 0.5735;

div_vec_2 = get_compared(Storage,processing,image_address_1,image_address_2, ...
    visual_map,visual_bar,'flow',flow_address,mean_target,max_target);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок третьей проверки
image_address_1 = 'demos/backstep_Re800_00007_img1.tif';
image_address_2 = 'demos/backstep_Re800_00007_img2.tif';
flow_address = 'demos/backstep_Re800_00007_flow.flo';
% vectors_map = load('vectors_map.mat');
visual_map = false; visual_bar = false;
mean_target = 0.0426; max_target = 1.2041;

div_vec_3 = get_compared(Storage,processing,image_address_1,image_address_2, ...
    visual_map,visual_bar,'flow',flow_address,mean_target,max_target);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок четвертой проверки
image_address_1 = 'demos/SQG_00001_img1.tif';
image_address_2 = 'demos/SQG_00001_img2.tif';
flow_address = 'demos/SQG_00001_flow.flo';
% vectors_map = load('vectors_map.mat');
visual_map = false; visual_bar = false;
mean_target = 0.4147; max_target = 4.3443;

div_vec_4 = get_compared(Storage,processing,image_address_1,image_address_2, ...
    visual_map,visual_bar,'flow',flow_address,mean_target,max_target);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Блок пятой проверки
image_address_1 = 'demos/cylinder_Re40_00001_img1.tif';
image_address_2 = 'demos/cylinder_Re40_00001_img2.tif';
flow_address = 'demos/cylinder_Re40_00001_flow.flo';
% vectors_map = load('vectors_map.mat');
visual_map = false; visual_bar = false;
mean_target = 0.0500; max_target = 0.4284;

div_vec_5 = get_compared(Storage,processing,image_address_1,image_address_2, ...
    visual_map,visual_bar,'flow',flow_address,mean_target,max_target);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Запись результатов
results_vec = cell(6,1);
results_vec{1} = name;
results_vec{2} = div_vec_1;
results_vec{3} = div_vec_2;
results_vec{4} = div_vec_3;
results_vec{5} = div_vec_4;
results_vec{6} = div_vec_5;
%--------------------------------------------------------------------------
