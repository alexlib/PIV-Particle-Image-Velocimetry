
clear Storage

Storage = Storage();

load_images(Storage,'demos/SQG_00001_img1.tif','demos/SQG_00001_img2.tif');

preprocessing(Storage);

pass(Storage,[32,32],[16,16],'type_pass','first','restriction','1/2');

validate_outliers(Storage);

interpolate_outliers(Storage);

smoothing(Storage);

pass(Storage,[16,16],[8,8],'type_pass','next'); % 'deform','symmetric'

validate_outliers(Storage);

interpolate_outliers(Storage);

smoothing(Storage);

pass(Storage,[8,8],[4,4],'type_pass','next');

validate_outliers(Storage,'threshold',1);

interpolate_outliers(Storage);

subpixel_peak(Storage,'method','centroid');

show(Storage);
