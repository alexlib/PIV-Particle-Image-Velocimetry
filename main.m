
% Задачи:
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
% 4 - pass                       - 
% 5 - images_split               - 
% 6 - peak_filter                - 
% 7 - validate_outliers          - 
% 8 - replace_outliers_next_peak - 
% 9 - interpolate_outliers       - 
% 10 - subpixel_peak             - 
% 11 - write_flow_file           - 
% 12 - show                      - 


clear Storage

Storage = Storage();

load_images(Storage,'VortexPair_1.tif','VortexPair_2.tif');

preprocessing(Storage);

pass(Storage,[64,64],[32,32],'type_pass','first');

validate_outliers(Storage,'threshold',1);

interpolate_outliers(Storage);

pass(Storage,[32,32],[16,16],'type_pass','next'); % 'deform','symmetric'

validate_outliers(Storage,'threshold',1);

interpolate_outliers(Storage);

pass(Storage,[16,16],[8,8],'type_pass','next');

validate_outliers(Storage,'threshold',1);

interpolate_outliers(Storage);

%subpixel_peak(Storage);

show(Storage); % визуализация
