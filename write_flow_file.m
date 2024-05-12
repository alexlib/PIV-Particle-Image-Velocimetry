function write_flow_file(Storage, filename,varargin)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

% Код взят с Github: https://github.com/seungryong/FCSS

% @InProceedings{kim2017,
% author = {Seungryong Kim and Dongbo Min and Bumsub Ham and Sangryul Jeon and Stephen Lin and Kwanghoon Sohn},
% title = {FCSS: Fully Convolutional Self-Similarity for Dense Semantic Correspondence},
% booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
% year = {2017}}

% Определиние стандартный параметров
scaling = false; % Радиус окрестности центральной точки (обычно устанавливается равным 1 или 2)

% Запись переданных параметров
k = 1;
while k <= size(varargin,2)
    switch varargin{k}
        case 'scaling'
            scaling = true;
        otherwise
            error('Указан неправильный параметр')
    end
    k = k + 1;
end

% Блок масштабирования векторного поля до размера изображения
if scaling
    Storage.vectors_map = imresize(Storage.vectors_map,size(Storage.image_1),'bilinear');
end

TAG_STRING = 'PIEH';    % use this when WRITING the file

% sanity check
if isempty(filename) == 1
    error('writeFlowFile: empty filename');
end

idx = strfind(filename, '.');
idx = idx(end);             % in case './xxx/xxx.flo'

if length(filename(idx:end)) == 1
    error('writeFlowFile: extension required in filename %s', filename);
end

if strcmp(filename(idx:end), '.flo') ~= 1    
    error('writeFlowFile: filename %s should have extension ''.flo''', filename);
end

[height,width,nBands] = size(Storage.vectors_map);

if nBands ~= 2
    error('writeFlowFile: image must have two bands');    
end

fid = fopen(filename, 'w');
if (fid < 0)
    error('writeFlowFile: could not open %s', filename);
end

% write the header
fwrite(fid, TAG_STRING); 
fwrite(fid, width, 'int32');
fwrite(fid, height, 'int32');

% arrange into matrix form
tmp = zeros(height, width*nBands);

tmp(:, (1:width)*nBands-1) = Storage.vectors_map(:,:,1);
tmp(:, (1:width)*nBands) = squeeze(Storage.vectors_map(:,:,2));
tmp = tmp';

fwrite(fid, tmp, 'float32');

fclose(fid);

end