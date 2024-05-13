function read_flow_file(Storage,filename)
%read_flow_file Чтение векторной карты из .flo файла
%   Считывает данные из файла и записывает в класс Storage

% Код взят с Github: https://github.com/seungryong/FCSS
% @InProceedings{kim2017,
% author = {Seungryong Kim and Dongbo Min and Bumsub Ham and Sangryul Jeon and Stephen Lin and Kwanghoon Sohn},
% title = {FCSS: Fully Convolutional Self-Similarity for Dense Semantic Correspondence},
% booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
% year = {2017}}

TAG_FLOAT = 202021.25;  % check for this when READING the file

% sanity check
if isempty(filename) == 1
    error('readFlowFile: empty filename');
end

idx = strfind(filename, '.');
idx = idx(end);

if length(filename(idx:end)) == 1
    error('readFlowFile: extension required in filename %s', filename);
end

if strcmp(filename(idx:end), '.flo') ~= 1    
    error('readFlowFile: filename %s should have extension ''.flo''', filename);
end

fid = fopen(filename, 'r');
if (fid < 0)
    error('readFlowFile: could not open %s', filename);
end

tag     = fread(fid, 1, 'float32');
width   = fread(fid, 1, 'int32');
height  = fread(fid, 1, 'int32');

% sanity check
if (tag ~= TAG_FLOAT)
    error('readFlowFile(%s): wrong tag (possibly due to big-endian machine?)', filename);
end

if (width < 1 || width > 99999)
    error('readFlowFile(%s): illegal width %d', filename, width);
end

if (height < 1 || height > 99999)
    error('readFlowFile(%s): illegal height %d', filename, height);
end

nBands = 2;

% arrange into matrix form
tmp = fread(fid, inf, 'float32');
tmp = reshape(tmp, [width*nBands, height]);
tmp = tmp';

% Запись векторного поля в класс Storage
Storage.vectors_map_last_pass(:,:,1) = tmp(:, (1:width)*nBands-1);
Storage.vectors_map_last_pass(:,:,2) = tmp(:, (1:width)*nBands);
Storage.vectors_map = Storage.vectors_map_last_pass;

% Инициализация новых масок
size_map = size(Storage.vectors_map,1:2);
Storage.outliers_map = zeros(size_map);
Storage.replaces_map = zeros(size_map);

fclose(fid);
end