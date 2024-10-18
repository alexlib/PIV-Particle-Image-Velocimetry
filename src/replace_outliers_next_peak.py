import numpy as np

def replace_outliers_next_peak(Storage, *args):
    """
    replace_outliers_next_peak Replace outliers with the 2nd and 3rd correlation peak
    It is possible to set a restriction on the search area for the correlation peak.
    """
    
    # Default parameters
    restriction = False

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'restriction':
            restriction = True
            restriction_area = args[k + 1]
            if restriction_area == '1/2':
                restriction_area = 1/2
            elif restriction_area == '1/3':
                restriction_area = 1/3
            elif restriction_area == '1/4':
                restriction_area = 1/4
            else:
                raise ValueError('Invalid parameter')
        else:
            raise ValueError('Incorrect parameter specified')
        k += 2

    # Determine the coordinates for the correlation peak search
    if restriction:  # with search area restriction
        x_start = Storage.window_size[1] - round(restriction_area * Storage.window_size[1])
        x_end = Storage.window_size[1] + round(restriction_area * Storage.window_size[1])
        y_start = Storage.window_size[0] - round(restriction_area * Storage.window_size[0])
        y_end = Storage.window_size[0] + round(restriction_area * Storage.window_size[0])
    else:  # without search area restriction
        x_start = 1
        x_end = 2 * Storage.window_size[1] - 1
        y_start = 1
        y_end = 2 * Storage.window_size[0] - 1

    # Convert the outliers mask to a vector of coordinates
    H, W = Storage.outliers_map.shape
    outliers_vector = []
    number_outliers = 0
    for i in range(H):
        for j in range(W):
            if Storage.outliers_map[i, j]:
                outliers_vector.append((i, j))
                number_outliers += 1

    # The rest of the function implementation goes here
    # ...

# Example usage
# storage = Storage()
# replace_outliers_next_peak(storage, 'restriction', '1/2')