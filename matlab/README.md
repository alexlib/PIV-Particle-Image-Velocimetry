# Документация проекта
Здесь приведена неформальная документация по коду и функциональная блок-схема.
Очередность использования модулей (методов) не строгая, возможно использовать в
другом порядке. Это только рекомендация к очередности модулей.

 <img src="/demos/FunctionSchema.png" width="400" />|<img src="/demos/FunctionSchemaAdd.png" width="300" /> 
|:--------------------------------------------------|-----------------------------------------------------:|

Описание модулей: <br>
**1.** `Storage` <br>
Класс хранения данных обработки. Через него осуществляется взаимодействие и
передача данных между функциями. <br>
Свойства (поля): <br>
`src_image_1` – первое исходное изображении <br>
`src_image_2` – второе исходное изображении <br>
`image_1` – первое обрабатываемое изображение <br>
`image_2` – второе обрабатываемое изображение <br>
`window_size` – размер окна опроса `[height, width]` <br>
`overlap` – величина наложения окон опроса `[height, width]` <br>
`centers_map` – матрица центров окон опроса на первом изображении <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`X = centers_map( : , : ,1)`; (столбцы `j`) <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`Y = centers_map( : , : ,2)`; (строки `i`) <br>
`vectors_map` – векторное поле <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`U = vectors_map( : , : ,1)` <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`V = vectors_map( : , : ,2)` <br>
`outliers_map` – маска выбросов <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`0` – выброс отсутствует <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`1` – выброс <br>
`replaces_map` – маска замещенных векторов <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`0` – вектор не замещен <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`1` – интерполирован <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`2` – замена 2-м корреляционным пиком <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`3` – замена 3-м корреляционным пиком <br>
`correlation_maps` – коллекция хранящая корреляционный карты <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`corr_map = correlation_maps{i, j}` <br>
`vectors_map_last_pass` – векторное поле последнего прохода <br>

**2.** `load_images(Storage, image_address_1, image_address_2)` <br>
Загрузка пары изображений в класс `Storage`. Поддерживаемые
форматы **jpg, jpeg, png, tif**.

**3.** `preprocessing(Storage)` <br>
Предобработка изображений. Выполняет перевод из цветного в черно-белое
изображение и приведение к типу данных **double**. Записывает
предобработанные изображения в класс `Storage`.

**4.** `pass(Storage, window_size, overlap, varargin)` <br>
Расчет векторного поля кросскорреляционным методом. В зависимости от
заданных параметров может работать, как проход для получения первичного
векторного поля, так и проход для уточнения существующего векторного поля. <br>
`varargin`: <br>
>`‘type_pass’` – тип прохода <br>
 `type_pass` = `‘first’` или `‘next’` <br>

>`‘double_corr’` = `true/false` – перемножение соседних корреляционных карт <br>
 `direct` = `‘x’`, `‘y’`, `‘xy’`, `‘center’` – метод перемножение <br>

>`‘restriction’` = `true/false` – ограничение области поиска корреляционного пика <br>
 `restriction_area` = `‘1/4’`, `‘1/3’`, `‘1/2’` – величина ограничения от размера окна <br>

>`‘deform’` = `true/false` – деформация изображений <br>
 `deform¬_type` = `‘symmetric‘` или `‘second’` – тип деформации <br>

>`‘borders’` – обработка границ изображений <br>
 `borders` = `true/false` <br>

Основные задачи разбить изображения на окна опроса, произвести кросскорреляцию
окон опроса и найти максимумы кросскорреляции. <br>
Опции: <br>
- Мультисеточный метод (`multigrid`), включается если в проходе изменить размеры (`windows_size`) или наложение (`overlap`) окон опроса относительно предыдущего прохода. <br>
- Деформация изображений (окон опроса) (`deform`). <br>
- Перемножение соседних корреляционных карт (`double_corr`) для уменьшения влияния шумов. <br>
- Ограничение области поиска корреляционного пика (`restriction`) для уменьшения количества ошибочных векторов, но жертвуем максимальной разрешаемой величиной вектора смещения. <br>
- Обработка, включая границы изображения (`borders`). <br>

