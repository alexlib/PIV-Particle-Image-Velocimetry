import numpy as np

def subpixel_peak(Storage, *args):
    """
    subpixel_peak Subpixel refinement of displacement magnitude
    It is possible to choose the method of approximation of the correlation peak.
    Interpolated vectors are not processed. If you want to use this method on non-integer values of the vector field, for example,
    after smoothing the vector field, you need to round to the nearest integer displacement (x_peak, y_peak).
    """
    
    # Default parameters
    eps = 2  # addition to exclude log(0)
    method = 'centroid'

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'method':
            method = args[k + 1]
        else:
            raise ValueError('Unknown method specified')
        k += 2

    # Remove the last pass and add a constant component to the correlation map
    Storage.vectors_map = Storage.vectors_map - Storage.vectors_map_last_pass

    # Approximation
    H, W = Storage.vectors_map_last_pass.shape[:2]
    for i in range(H):
        for j in range(W):
            Storage.correlation_maps[i, j] += eps
            if (Storage.replaces_map[i, j] == 0) or (Storage.replaces_map[i, j] > 1):  # interpolated vectors are not processed
                x_peak = Storage.vectors_map_last_pass[i, j, 0] + Storage.window_size[1]
                y_peak = Storage.vectors_map_last_pass[i, j, 1] + Storage.window_size[0]
                # Check for boundary values (boundaries are not processed)
                if (x_peak == 1) or (y_peak == 1) or (x_peak == 2 * Storage.window_size[1] - 1) or (y_peak == 2 * Storage.window_size[0] - 1):
                    Storage.vectors_map[i, j] += Storage.vectors_map_last_pass[i, j]
                else:
                    center = Storage.correlation_maps[i, j][y_peak, x_peak]
                    left = Storage.correlation_maps[i, j][y_peak, x_peak - 1]
                    right = Storage.correlation_maps[i, j][y_peak, x_peak + 1]
                    down = Storage.correlation_maps[i, j][y_peak + 1, x_peak]
                    up = Storage.correlation_maps[i, j][y_peak - 1, x_peak]

                    # Continue with the rest of the approximation logic
                    # ...

# Example usage
# subpixel_peak(Storage, 'method', 'centroid')