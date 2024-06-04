function processing_1(Storage)
% Однопроходный сценарий

preprocessing(Storage);

pass(Storage,[32,32],[24,24],'type_pass','first','restriction','1/3');
validate_outliers(Storage);
interpolate_outliers(Storage);
subpixel_peak(Storage);

end