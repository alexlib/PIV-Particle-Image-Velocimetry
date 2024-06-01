function smoothing(Storage)
%smoothing Сглаживание векторного поля
%   Улучшает гладкость векторного поля

% Сглаживание данных медианной окрестности
Storage.vectors_map = smoothdata2(Storage.vectors_map,"movmedian",4);
Storage.vectors_map_last_pass = smoothdata2(Storage.vectors_map_last_pass,"movmedian",4);

end