function resize_field(Storage,size_map)
%resize_field Масштабирование векторного поля
%   Выполняет масштабирование векторного поля в соответствии с новыми
%   размерами и наложением окон опроса

% Метод масштабирования
Storage.vectors_map = imresize(Storage.vectors_map,size_map,'bilinear');

end
