function deform_images(Storage,deform_type)
%deform_images Деформация изображений
%   Выполняет деформации изображений в соответствии с векторным полем
%   последнего прохода

% Масштабирование векторного поля до размера изображения
Storage.vectors_map_last_pass = imresize(Storage.vectors_map_last_pass,size(Storage.image_1),'bilinear');

% Методы деформации изображений
switch deform_type
    case 'symmetric'
        Storage.image_1 = imwarp(Storage.image_1,-Storage.vectors_map_last_pass/2,'cubic');
        Storage.image_2 = imwarp(Storage.image_2,Storage.vectors_map_last_pass/2,'cubic');
    case 'second'
        Storage.image_2 = imwarp(Storage.image_2,Storage.vectors_map_last_pass,'nearest');
    otherwise , error('Указан неизвестный метод');
end

end