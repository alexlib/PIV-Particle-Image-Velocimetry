clear Storage
Storage = Storage();

folder_address = 'JHTDB_channel_hd';
image_format = '*.tif';

processing_vec{1,1} = @processing_1;
processing_vec{2,1} = @processing_2;
processing_vec{3,1} = @processing_3;
processing_vec{4,1} = @processing_4;

data = get_compared_group(Storage,folder_address,image_format,processing_vec);

% Визуализация
build_graphs_group(data);
