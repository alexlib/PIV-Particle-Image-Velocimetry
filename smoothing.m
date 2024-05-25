function smoothing(Storage)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

Storage.vectors_map = smoothdata2(Storage.vectors_map,"movmedian",4);
Storage.vectors_map_last_pass = smoothdata2(Storage.vectors_map_last_pass,"movmedian",4);

end