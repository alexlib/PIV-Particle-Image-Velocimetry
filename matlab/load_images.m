function load_images(Storage,image_address_1,image_address_2)
%load_images Загрузка изображений в класс Storage
%   Поддерживает форматы jpg, jpeg, png, tif

Storage.src_image_1 = imread(image_address_1);
Storage.src_image_2 = imread(image_address_2);

end