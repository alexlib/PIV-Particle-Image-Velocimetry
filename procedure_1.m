function procedure_1(Storage)

pass(Storage,[64,64],[32,32],'type_pass','first','restriction','1/4');

validate_outliers(Storage);

interpolate_outliers(Storage);

pass(Storage,[32,32],[16,16],'type_pass','next','deform','second');

validate_outliers(Storage);

interpolate_outliers(Storage);

pass(Storage,[16,16],[12,12],'type_pass','next','deform','second');

validate_outliers(Storage,'threshold',1);

interpolate_outliers(Storage);

subpixel_peak(Storage,'method','centroid');

show(Storage); % визуализация

end