
% Задачи:
% №1 Описать код (комментарии)
% №2 Протестировать весь код
% №3 Удалить отладочный код
% №4 Проверить орфографию комментариев
% №5 Повторно убедиться в работоспособности кода
% №6 Загрузить промежуточный результат на GitHub

% 12 функций не считая main и один класс Storage.
% класс Storage                  - 
% 1 - load_images                - 
% 2 - preprocessing              - 
% 3 - read_flow_file             - 
% 4 - pass
% 5 - images_split
% 6 - peak_filter
% 7 - validate_outliers
% 8 - replace_outliers_next_peak
% 9 - interpolate_outliers
% 10 - subpixel_peak
% 11 - write_flow_file
% 12 - show


clear Storage

Storage = Storage();

load_images(Storage,'SQG_00001_img1.tif','SQG_00001_img2.tif');

preprocessing(Storage);

