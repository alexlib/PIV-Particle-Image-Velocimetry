
% Сценарий проверки
procedure = @procedure_1;

% Название сценария для графика
name = 'first';

% % Блок первой проверки
% clear Storage
% Storage = Storage();
% image_address_1 = 'uniform_00001_img1.tif';
% image_address_2 = 'uniform_00001_img2.tif';
% flow_address = 'uniform_00001_flow.flo';
% vec_1 = test(Storage,procedure,image_address_1,image_address_2,flow_address);
% 
% % Блок второй проверки
% clear Storage
% Storage = Storage();
% image_address_1 = 'JHTDB_channel_00176_img1.tif';
% image_address_2 = 'JHTDB_channel_00176_img2.tif';
% flow_address = 'JHTDB_channel_00176_flow.flo';
% vec_2 = test(Storage,procedure,image_address_1,image_address_2,flow_address);
% 
% % Блок третьей проверки
% clear Storage
% Storage = Storage();
% image_address_1 = 'backstep_Re800_00007_img1.tif';
% image_address_2 = 'backstep_Re800_00007_img2.tif';
% flow_address = 'backstep_Re800_00007_flow.flo';
% vec_3 = test(Storage,procedure,image_address_1,image_address_2,flow_address);

% Блок четвертой проверки
clear Storage
Storage = Storage();
image_address_1 = 'SQG_00001_img1.tif';
image_address_2 = 'SQG_00001_img2.tif';
flow_address = 'SQG_00001_flow.flo';
vec_4 = test(Storage,procedure,image_address_1,image_address_2,flow_address);

% % Блок пятой проверки
% clear Storage
% Storage = Storage();
% image_address_1 = 'cylinder_Re40_00001_img1.tif';
% image_address_2 = 'cylinder_Re40_00001_img2.tif';
% flow_address = 'cylinder_Re40_00001_flow.flo';
% vec_5 = test(Storage,procedure,image_address_1,image_address_2,flow_address);
% 
% % Выгрузка данных (не забудь сохранить)
% accuracy_1 = cell(6,1);
% accuracy_1{1} = name;
% accuracy_1{2} = vec_1;
% accuracy_1{3} = vec_2;
% accuracy_1{4} = vec_3;
% accuracy_1{5} = vec_4;
% accuracy_1{6} = vec_5;
