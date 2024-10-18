import numpy as np

def search_peak(Storage, size_map, restriction, restriction_area):
    """
    search_peak Search for the correlation maximum
    Performs a search for the correlation peak. For outliers, no search is performed, and zero displacement is recorded.
    """
    
    # Initialize a new vector field for the last pass
    Storage.vectors_map_last_pass = np.zeros((size_map[0], size_map[1], 2))

    # Peak search
    if restriction:  # with search area restriction
        x_start = Storage.window_size[1] - round(restriction_area * Storage.window_size[1])
        x_end = Storage.window_size[1] + round(restriction_area * Storage.window_size[1])
        y_start = Storage.window_size[0] - round(restriction_area * Storage.window_size[0])
        y_end = Storage.window_size[0] + round(restriction_area * Storage.window_size[0])
        for i in range(size_map[0]):
            for j in range(size_map[1]):
                if Storage.outliers_map[i, j]:  # for outliers, record zero displacement
                    Storage.vectors_map_last_pass[i, j, :] = [0, 0]
                    Storage.outliers_map[i, j] = 0  # exclude from outliers (maybe should not exclude)
                else:
                    limit_corr_map = Storage.correlation_maps[i, j][y_start:y_end, x_start:x_end]
                    y_peak, x_peak = np.unravel_index(np.argmax(limit_corr_map), limit_corr_map.shape)
                    Storage.vectors_map_last_pass[i, j, :] = [x_peak - Storage.window_size[1] + x_start - 1, y_peak - Storage.window_size[0] + y_start - 1]
    else:  # without search area restriction
        for i in range(size_map[0]):
            for j in range(size_map[1]):
                if Storage.outliers_map[i, j]:
                    Storage.vectors_map_last_pass[i, j, :] = [0, 0]
                    Storage.outliers_map[i, j] = 0
                else:
                    y_peak, x_peak = np.unravel_index(np.argmax(Storage.correlation_maps[i, j]), Storage.correlation_maps[i, j].shape)
                    Storage.vectors_map_last_pass[i, j, :] = [x_peak - Storage.window_size[1], y_peak - Storage.window_size[0]]

# Example usage
# storage = Storage()
# search_peak(storage, (100, 100), True, 0.5)