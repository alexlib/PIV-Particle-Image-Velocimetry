function processing_3(Storage)
% Трехпроходный сценарий с деформацией

preprocessing(Storage);

pass(Storage,[32,32],[16,16],'type_pass','first');
validate_outliers(Storage);
interpolate_outliers(Storage);
smoothing(Storage);

pass(Storage,[16,16],[8,8],'type_pass','next','deform','symmetric');
validate_outliers(Storage);
interpolate_outliers(Storage);
smoothing(Storage);

pass(Storage,[8,8],[4,4],'type_pass','next','double_corr','xy','deform','symmetric');
validate_outliers(Storage);
interpolate_outliers(Storage);
subpixel_peak(Storage);

end