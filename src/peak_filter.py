import numpy as np

def peak_filter(Storage, *args):
    """
    peak_filter Outlier detection in vector fields
    Parses the given parameters and checks for outliers in the vector field.
    """
    
    # Default parameter definitions
    threshold = None
    single = False
    i_single = None
    j_single = None

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'threshold':
            threshold = args[k + 1]
        elif args[k] == 'single':
            single = True
            i_single = args[k + 1][0]
            j_single = args[k + 1][1]
        else:
            raise ValueError('Incorrect parameter specified')
        k += 2

    # Outlier check
    if single:  # single vector
        x_peak = Storage.vectors_map_last_pass[i_single, j_single, 0] + Storage.window_size[1]
        y_peak = Storage.vectors_map_last_pass[i_single, j_single, 1] + Storage.window_size[0]
        if Storage.correlation_maps[i_single, j_single][y_peak, x_peak] < threshold:
            return True
        else:
            return False
    else:  # all vectors
        for i in range(Storage.vectors_map_last_pass.shape[0]):
            for j in range(Storage.vectors_map_last_pass.shape[1]):
                x_peak = Storage.vectors_map_last_pass[i, j, 0] + Storage.window_size[1]
                y_peak = Storage.vectors_map_last_pass[i, j, 1] + Storage.window_size[0]
                if Storage.correlation_maps[i, j][y_peak, x_peak] < threshold:
                    Storage.outliers_map[i, j] = 1

# Example usage
# peak_filter(Storage, 'threshold', 0.5, 'single', [1, 2])