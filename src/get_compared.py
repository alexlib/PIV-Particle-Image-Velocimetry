import numpy as np
from skimage import io


def get_compared(Storage, procedure, image_address_1, image_address_2, visual_map, visual_bar, *args):
    """
    get_compared Compare the given vector field with the processing result
    Finds the arithmetic mean of the deviation modulus of two fields and the maximum deviation along one of the coordinates
    """
    
    # Ensure comparison vector field parameters are provided
    if not args:
        raise ValueError('Parameters not provided')

    # Default parameters
    flow = False
    compare = False
    mean_target = 0
    max_target = 0

    # Parameter parser
    k = 0
    if args[k] == 'flow':
        flow = True
        k += 1
        flow_address = args[k]
    elif args[k] == 'custom':
        k += 1
        vectors_map = args[k]
    else:
        raise ValueError('Invalid parameter')

    if len(args) > k + 1:
        compare = True
        k += 1
        mean_target = args[k]

    if len(args) > k + 1:
        max_target = args[k + 1]

    # Load images
    load_images(Storage, image_address_1, image_address_2)

    # Load the original (comparison) field
    if flow:
        read_flow_file(Storage, flow_address)
        true_map = Storage.vectors_map

    # Запуск заданного сценария
    procedure(Storage)
    result_map = Storage.vectors_map

    # Визуализация результатов сценария
    if visual_map:
        show(Storage)
        pause.on()
        pause()

    # Расчет матрицы отклонений по модулю
    if flow:  # в сравнении с полем из файла flow
        H, W, B = result_map.shape
        div_map = np.zeros((H, W, B))
        for i in range(H):
            for j in range(W):
                for c in range(2):
                    div_map[i, j, c] = abs(result_map[i, j, c] - true_map[Storage.centers_map[i, j, 2], Storage.centers_map[i, j, 1], c])
    else:  # в сравнении с полем с указанными координатами вектором
        if vectors_map.shape != result_map.shape:
            raise ValueError('Size mismatch')
        H, W, B = vectors_map.shape
        div_map = np.zeros((H, W, B))
        for i in range(H):
            for j in range(W):
                for c in range(2):
                    div_map[i, j, c] = abs(result_map[i, j, c] - vectors_map[i, j, c])

    # Расчет среднего арифметического отклонения и максимума отклонения
    div_mean = np.sum(div_map) / (H * W * B)
    div_max = np.max(div_map)

    # Запись результатов
    div_vec = [div_mean, div_max]

    # Визуализация результатов среднеарифметического и максимума отклонения
    if visual_bar:
        if compare:
            get_graph([div_vec[0], div_vec[1], mean_target, max_target])
        else:
            get_graph([div_vec[0], div_vec[1]])

def get_graph(bar_values):
    b = bar(bar_values, 'grouped', 'FaceColor', 'flat')

    xtips1 = b[0].XEndPoints
    ytips1 = b[0].YEndPoints
    labels1 = [str(y) for y in b[0].YData]
    text(xtips1, ytips1, labels1, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

    if len(bar_values) > 2:
        xtips2 = b[1].XEndPoints
        ytips2 = b[1].YEndPoints
        labels2 = [str(y) for y in b[1].YData]
        text(xtips2, ytips2, labels2, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')

        b[1].CData[0, :] = [0.85, 0.325, 0.098]
        b[1].CData[1, :] = b[1].CData[0, :]
    else:
        b.CData[1, :] = [0.85, 0.325, 0.098]

    pause.on()
    pause()

# Example usage
# storage = Storage()
# get_compared(storage, 'procedure', 'path/to/image1.tif', 'path/to/image2.tif', True, True, 'flow', 'path/to/flow.flo')
