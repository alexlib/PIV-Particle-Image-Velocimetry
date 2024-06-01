function show(Storage)
%show Визуализатор результатов обработки

% Создание окна
fig = uifigure('Position',[200 100 1000 600]);
% Определение двух областей
grid1 = uigridlayout(fig,[1 2]);
% Определение ширины левой области
grid1.ColumnWidth = {200,'1x'};
% Подпись левой области
p = uipanel(grid1,'Title','Configuration');
% Добавление координатных осей в правую область и colorbar
ax = uiaxes(grid1); colorbar(ax);

% Число графиков, содержащихся у родителя
list_Graphics = 0;
% Фон
background = imshow((Storage.image_1+Storage.image_2)/2,'DisplayRange',[0,255], 'Parent', ax);
hold(ax, 'on')
list_Graphics = list_Graphics + 1;
% Если не рассчитаны центры окон опроса, то принимаем за центры каждый пиксель изображения
if isempty(Storage.centers_map)
    [Storage.centers_map(:,:,1),Storage.centers_map(:,:,2)] = meshgrid(1:size(Storage.image_1,1),1:size(Storage.image_1,2));
end
% Отображение векторного поля со стандартными параметрами
[dv,do,di,dr2,dr3,ovm,ivm,r2vm,r3vm] = visual_vectors(Storage,ax,1.0,2.0,{'green','red','blue','magenta','cyan'});
list_Graphics = list_Graphics + 5;
% Расчёт графика линии (не отображается в начале)
streamslice(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),Storage.vectors_map(:,:,1),Storage.vectors_map(:,:,2),'Parent', ax);
set(ax.Children(1:end-list_Graphics),'Color','none');

% Разбиение на области левой колонки
grid2 = uigridlayout(p,[16 2]);
grid2.RowHeight = {20,20,20,20,20,40,40,40,20,20,20,40,40,20};
grid2.ColumnWidth = 75;
% Массив доступных цветов
colors = {'green','red','blue','magenta','cyan','yellow','black','white','none'};

% Выпадающий список для обычных векторов
uilabel(grid2,HorizontalAlignment ='left',Text ='Vectors');
vectorsDrop = uidropdown(grid2,"Items",colors,"ValueChangedFcn",@(src,event) set(dv,'Color',src.Value));
vectorsDrop.Layout.Row = 1; vectorsDrop.Layout.Column  = 2;

% Выпадающий список для выбросов
uilabel(grid2,HorizontalAlignment ='left',Text ='Outliers');
uidropdown(grid2,"Items",{colors{2},colors{1},colors{3:end}},"ValueChangedFcn",@(src,event) set(do,'Color',src.Value));

% Выпадающий список для интерполяции
uilabel(grid2,HorizontalAlignment ='left',Text ='Interpolate');
uidropdown(grid2,"Items",{colors{3},colors{1:2},colors{4:end}},"ValueChangedFcn",@(src,event) set(di,'Color',src.Value));

% Выпадающий список для замены 2-го порядка
uilabel(grid2,HorizontalAlignment ='left',Text ='Replace_2nd');
uidropdown(grid2,"Items",{colors{4},colors{1:3},colors{5:end}},"ValueChangedFcn",@(src,event) set(dr2,'Color',src.Value));

% Выпадающий список для замены 3-го порядка
uilabel(grid2,HorizontalAlignment ='left',Text ='Replace_3nd');
uidropdown(grid2,"Items",{colors{5},colors{1:4},colors{6:end}},"ValueChangedFcn",@(src,event) set(dr3,'Color',src.Value));

% Ползунок плотности векторного поля
uilabel(grid2,HorizontalAlignment ='left',Text = sprintf('%s\n%s','Density'));
density_slider = uislider(grid2,"Limits",[1,10],"MajorTicks",[1,2,3,4,5,7,10],"ValueChangedFcn",@(src,event) change_density(src,Storage,dv,ovm,do,ivm,di,r2vm,dr2,r3vm,dr3));

% Ползунок масштаба
uilabel(grid2,HorizontalAlignment ='left',Text ='Scale');
uislider(grid2,"Limits",[1,20],"MajorTicks",[1,5,10,15,20],"ValueChangedFcn",@(src,event) change_scale(src,Storage,round(density_slider.Value),dv,ovm,do,ivm,di,r2vm,dr2,r3vm,dr3));

% Ползунок толщины стрелки
uilabel(grid2,HorizontalAlignment ='left',Text ='Linewidth');
uislider(grid2,"Limits",[0.1,5],"Value",2.0,"MajorTicks",[0.1,1,2,3,4,5],"ValueChangedFcn",@(src,event) change_linewidth(src,dv,do,di,dr2,dr3));

% Выпадающий список для выбора цветовой карты
colormapName = {'parula','turbo','hsv','hot','cool','spring','summer','autumn','winter','gray','bone','copper','pink','jet','lines','colorcube','prism','flag','white'};
colormapData = {parula,turbo,hsv,hot,cool,spring,summer,autumn,winter,gray,bone,copper,pink,jet,lines,colorcube,prism,flag,white};
colormapLabel = uilabel(grid2,HorizontalAlignment ='left',Text ='Colormap');
colormapLabel.Layout.Row = 10; colormapLabel.Layout.Column  = 1;
colormapDrop = uidropdown(grid2,"Items",colormapName,'ItemsData',colormapData,'Value',gray,"ValueChangedFcn",@(src,event) set(ax,'Colormap',src.Value));
colormapDrop.Layout.Row = 10; colormapDrop.Layout.Column  = 2;

% Выпадающий список для выбора фона
backgroundList = {'mean image','magnitude','vorticity','white','black','image 1','image 2','src image 1','src image 2'};
backgroundLabel = uilabel(grid2,HorizontalAlignment ='left',Text ='Background');
backgroundLabel.Layout.Row = 9; backgroundLabel.Layout.Column  = 1;
backgroundDrop = uidropdown(grid2,"Items",backgroundList,"ValueChangedFcn",@(src,event) change_background(src,Storage,background,colormapDrop,ax));
backgroundDrop.Layout.Row = 9; backgroundDrop.Layout.Column  = 2;

% Выбор цвета графика линий
uilabel(grid2,HorizontalAlignment ='left',Text ='Streamslice');
uidropdown(grid2,"Items",{colors{end},colors{1:end-1}},"ValueChangedFcn",@(src,event) set(ax.Children(1:end-list_Graphics),'Color',src.Value));

% Ползунок толщины графика линий
uilabel(grid2,HorizontalAlignment ='left',Text = sprintf('%s\n%s','Streamslice','Linewidth'));
uislider(grid2,"Limits",[0.1,5],"Value",1.0,"MajorTicks",[0.1,1,2,3,4,5],"ValueChangedFcn",@(src,event) set(ax.Children(1:end-list_Graphics),'LineWidth',src.Value));

% Ползунок плотности графика линий
uilabel(grid2,HorizontalAlignment ='left',Text = sprintf('%s\n%s','Streamslice','Density'));
uislider(grid2,"Limits",[1,20],"MajorTicks",[1,5,10,15,20],"ValueChangedFcn",@(src,event) change_density_streamslice(src,Storage,list_Graphics,ax));

% Отображение окон опроса
cbx = uicheckbox(grid2,'Text','Show sliding windows','ValueChangedFcn',@(src,event) visual_sliding_windows(src,Storage,ax));
cbx.Layout.Column = 1:2;

end

function visual_sliding_windows(src,Storage,parent)

size_map = size(Storage.centers_map,1:2);
if src.Value
    for i = 1:size_map(1)
        for j = 1:size_map(2)
            xc = Storage.centers_map(i,j,1);
            yc = Storage.centers_map(i,j,2);
            w = Storage.window_size(2);
            h = Storage.window_size(1);
            % Поправка в 0.5 связанна с отрисовкой прямоугольников
            x0 = xc - round(w/2) + 0.5;
            y0 = yc - round(h/2) + 0.5;
            % Визуализация прямоугольников и маркеров
            if (i == 1)||(j == 1)||(i == size_map(1))||(j == size_map(2)) % граничные окна опроса подкрашены другим цветом
                rectangle('Position',[x0 y0 w h],'EdgeColor','red','LineWidth',2.0,'Parent', parent);
                plot(xc,yc,'-s','MarkerFaceColor','red','MarkerEdgeColor','red','MarkerSize',5,'Parent', parent);
            else
                rectangle('Position',[x0 y0 w h],'EdgeColor','yellow','LineWidth',1.5,'Parent', parent);
                plot(xc,yc,'-s','MarkerFaceColor','green','MarkerEdgeColor','green','MarkerSize',5,'Parent', parent);
            end
        end
    end
else % если убрана галочка, то удалить отрисованные прямоугольники и маркера
    size_prev = 2*size_map(1)*size_map(2);
    delete(parent.Children(1:size_prev));
end

end

function change_density(src,Storage,dv,ovm,do,ivm,di,r2vm,dr2,r3vm,dr3)    

density = round(src.Value);

dv.XData = Storage.centers_map(1:density:end,1:density:end,1);
dv.YData = Storage.centers_map(1:density:end,1:density:end,2);
dv.UData = Storage.vectors_map(1:density:end,1:density:end,1);
dv.VData = Storage.vectors_map(1:density:end,1:density:end,2);

do.XData = Storage.centers_map(1:density:end,1:density:end,1);
do.YData = Storage.centers_map(1:density:end,1:density:end,2);
do.UData = ovm(1:density:end,1:density:end,1);
do.VData = ovm(1:density:end,1:density:end,2);

di.XData = Storage.centers_map(1:density:end,1:density:end,1);
di.YData = Storage.centers_map(1:density:end,1:density:end,2);
di.UData = ivm(1:density:end,1:density:end,1);
di.VData = ivm(1:density:end,1:density:end,2);

dr2.XData = Storage.centers_map(1:density:end,1:density:end,1);
dr2.YData = Storage.centers_map(1:density:end,1:density:end,2);
dr2.UData = r2vm(1:density:end,1:density:end,1);
dr2.VData = r2vm(1:density:end,1:density:end,2);

dr3.XData = Storage.centers_map(1:density:end,1:density:end,1);
dr3.YData = Storage.centers_map(1:density:end,1:density:end,2);
dr3.UData = r3vm(1:density:end,1:density:end,1);
dr3.VData = r3vm(1:density:end,1:density:end,2);

end

function change_density_streamslice(src,Storage,list_Graphics,parent)

% Расчёт количества графических объектов типа 'Line'
size_prev = size(parent.Children,1) - list_Graphics;
% Запоминаем цвет и толщину линии предыдущего streamslice
color = parent.Children(1).Color;
linewidth = parent.Children(1).LineWidth;
% Удаляем предыдущие 'Line'
delete(parent.Children(1:size_prev));
% Добавляем новые 'Line'
streamslice(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),Storage.vectors_map(:,:,1),Storage.vectors_map(:,:,2),src.Value,'Parent', parent);
% Устанавливаем параметры предыдущего streamslice
set(parent.Children(1:end-list_Graphics),'Color',color);
set(parent.Children(1:end-list_Graphics),'LineWidth',linewidth);

end

function change_background(src,Storage,background,colormapDrop,parent)

switch src.Value
    case 'mean image'
        background.CData = (Storage.image_1+Storage.image_2)/2;
        parent.CLim = [0 255];
        colormapDrop.Value = gray;
        parent.Colormap = gray;
    case 'magnitude'
        magnitude = sqrt(Storage.vectors_map(:,:,1).^(2)+Storage.vectors_map(:,:,2).^(2));
        magnitude = imresize(magnitude,size(Storage.image_1,1:2),"bicubic");
        m_max = max(magnitude,[],'all');
        background.CData = magnitude;
        parent.CLim = [0 m_max];
        colormapDrop.Value = jet;
        parent.Colormap = jet;
    case 'vorticity'
        cav = curl(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),Storage.vectors_map(:,:,1),Storage.vectors_map(:,:,2));
        cav = imresize(cav,[size(Storage.image_1,1:2)],"bicubic");
        c_max = max(cav,[],'all');
        c_min = min(cav,[],'all');
        background.CData = cav;
        parent.CLim = [c_min c_max];
        colormapDrop.Value = jet;
        parent.Colormap = jet;
    case 'white'
        background.CData = ones(size(Storage.image_1));
        parent.CLim = [0 1];
        colormapDrop.Value = gray;
        parent.Colormap = gray;
    case 'black'
        background.CData = zeros(size(Storage.image_1));
        parent.CLim = [0 1];
        colormapDrop.Value = gray;
        parent.Colormap = gray;
    case 'image 1'
        background.CData = Storage.image_1;
        parent.CLim = [0 255];
        colormapDrop.Value = gray;
        parent.Colormap = gray;
    case 'image 2'
        background.CData = Storage.image_2;
        parent.CLim = [0 255];
        colormapDrop.Value = gray;
        parent.Colormap = gray;
    case 'src image 1'
        background.CData = Storage.src_image_1;
        parent.CLim = [0 255];
    case 'src image 2'
        background.CData = Storage.src_image_2;
        parent.CLim = [0 255];
end

end

function change_scale(src,Storage,density,dv,ovm,do,ivm,di,r2vm,dr2,r3vm,dr3)

scale = src.Value;

dv.UData = Storage.vectors_map(1:density:end,1:density:end,1)*scale;
dv.VData = Storage.vectors_map(1:density:end,1:density:end,2)*scale;

do.UData = ovm(1:density:end,1:density:end,1)*scale;
do.VData = ovm(1:density:end,1:density:end,2)*scale;

di.UData = ivm(1:density:end,1:density:end,1)*scale;
di.VData = ivm(1:density:end,1:density:end,2)*scale;

dr2.UData = r2vm(1:density:end,1:density:end,1)*scale;
dr2.VData = r2vm(1:density:end,1:density:end,2)*scale;

dr3.UData = r3vm(1:density:end,1:density:end,1)*scale;
dr3.VData = r3vm(1:density:end,1:density:end,2)*scale;

end

function change_linewidth(src,dv,do,di,dr2,dr3)

dv.LineWidth = src.Value;
do.LineWidth = src.Value;
di.LineWidth = src.Value;
dr2.LineWidth = src.Value;
dr3.LineWidth = src.Value;

end

function [dv,do,di,dr2,dr3,outliers_vectors_map,interpolate_vectors_map,replace_2nd_vectors_map,replace_3nd_vectors_map] = visual_vectors(Storage,parent,scale,linewidth,colorvec)

[H,W] = size(Storage.vectors_map,1:2);

% Инициализация и запись векторов из масок выбросов и замен
outliers_vectors_map = zeros(H,W,2);
for i = 1:H
    for j = 1:W
        if Storage.outliers_map(i,j) > 0
            outliers_vectors_map(i,j,:) = Storage.vectors_map(i,j,:);
        end
    end
end

interpolate_vectors_map = zeros(H,W,2);
for i = 1:H
    for j = 1:W
        if Storage.replaces_map(i,j) == 1
            interpolate_vectors_map(i,j,:) = Storage.vectors_map(i,j,:);
        end
    end
end

replace_2nd_vectors_map = zeros(H,W,2);
for i = 1:H
    for j = 1:W
        if Storage.replaces_map(i,j) == 2
            replace_2nd_vectors_map(i,j,:) = Storage.vectors_map(i,j,:);
        end
    end
end

replace_3nd_vectors_map = zeros(H,W,2);
for i = 1:H
    for j = 1:W
        if Storage.replaces_map(i,j) == 3
            replace_3nd_vectors_map(i,j,:) = Storage.vectors_map(i,j,:);
        end
    end
end

% Создание дескрипторов функции отрисовки векторов
draw_vectors_map = @(x,y,u,v) quiver(x,y,u*scale,v*scale,'AutoScale','off','Linewidth',linewidth,'Color',colorvec{1},'Parent', parent);
draw_outliers = @(x,y,u,v) quiver(x,y,u*scale,v*scale,'AutoScale','off','Linewidth',linewidth,'Color',colorvec{2},'Parent', parent);
draw_interpolate = @(x,y,u,v) quiver(x,y,u*scale,v*scale,'AutoScale','off','Linewidth',linewidth,'Color',colorvec{3},'Parent', parent);
draw_replace_2nd = @(x,y,u,v) quiver(x,y,u*scale,v*scale,'AutoScale','off','Linewidth',linewidth,'Color',colorvec{4},'Parent', parent);
draw_replace_3nd = @(x,y,u,v) quiver(x,y,u*scale,v*scale,'AutoScale','off','Linewidth',linewidth,'Color',colorvec{5},'Parent', parent);

% Вывод векторных полей
dv = draw_vectors_map(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),Storage.vectors_map(:,:,1),Storage.vectors_map(:,:,2));
do = draw_outliers(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),outliers_vectors_map(:,:,1),outliers_vectors_map(:,:,2));
di = draw_interpolate(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),interpolate_vectors_map(:,:,1),interpolate_vectors_map(:,:,2));
dr2 = draw_replace_2nd(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),replace_2nd_vectors_map(:,:,1),replace_2nd_vectors_map(:,:,2));
dr3 = draw_replace_3nd(Storage.centers_map(:,:,1),Storage.centers_map(:,:,2),replace_3nd_vectors_map(:,:,1),replace_3nd_vectors_map(:,:,2));

end
