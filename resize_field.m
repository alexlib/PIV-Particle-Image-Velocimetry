function resize_field(Storage,size_map)

Storage.vectors_map = imresize(Storage.vectors_map,size_map,'bilinear');

end