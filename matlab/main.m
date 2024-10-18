% Пример работы программы с визуализацией результатов и примеры различных
% сценариев обработки

%--------------------------------------------------------------------------
% Пример сценария обработки
clear Storage
Storage = Storage();

load_images(Storage,'../demos/SQG_00001_img1.tif','../demos/SQG_00001_img2.tif');
preprocessing(Storage);

pass(Storage,[32,32],[16,16],'type_pass','first','restriction','1/2');
validate_outliers(Storage);
interpolate_outliers(Storage);
smoothing(Storage);

pass(Storage,[16,16],[8,8],'type_pass','next','deform','symmetric');
validate_outliers(Storage);
interpolate_outliers(Storage);
smoothing(Storage);

pass(Storage,[8,8],[4,4],'type_pass','next','deform','symmetric','double_corr','xy');
validate_outliers(Storage,'radius',1,'threshold',0.5);
interpolate_outliers(Storage,'radius',1);
subpixel_peak(Storage);

show(Storage);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Трехпроходный максимально загруженный сценарий
% clear Storage
% Storage = Storage();
% 
% load_images(Storage,'.../demos/backstep_Re800_00007_img1.tif','.../demos/backstep_Re800_00007_img2.tif');
% preprocessing(Storage);
% 
% pass(Storage,[36,31],[11,17],'type_pass','first','double_corr','center','restriction','1/3');
% peak_filter(Storage,'threshold', 0.6);
% validate_outliers(Storage,'radius',2,'threshold',1.2,'noise',0.6);
% replace_outliers_next_peak(Storage,'restriction','1/3');
% interpolate_outliers(Storage,'radius',2);
% smoothing(Storage)
% 
% pass(Storage,[16,16],[10,10],'type_pass','next','double_corr','xy','restriction','1/2','deform','symmetric');
% peak_filter(Storage);
% validate_outliers(Storage);
% replace_outliers_next_peak(Storage);
% interpolate_outliers(Storage);
% smoothing(Storage)
% 
% pass(Storage,[8,8],[4,4],'type_pass','next','restriction','1/2','deform','second');
% peak_filter(Storage);
% validate_outliers(Storage);
% replace_outliers_next_peak(Storage);
% interpolate_outliers(Storage);
% subpixel_peak(Storage,'method','centroid');
% 
% show(Storage)
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
% Однопроходный минимальный сценарий
% clear Storage
% Storage = Storage();
% 
% load_images(Storage,'.../demos/VortexPair_1.tif','.../demos/VortexPair_2.tif');
% preprocessing(Storage);
% 
% pass(Storage,[48,48],[32,32],'type_pass','first');
% 
% show(Storage)
%--------------------------------------------------------------------------
