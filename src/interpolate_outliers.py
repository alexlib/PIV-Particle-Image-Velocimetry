import numpy as np
from scipy.ndimage import median_filter

def interpolate_outliers(Storage, *args):
    """
    interpolate_outliers Replace outliers with the median value of the neighborhood
    It is possible to set the size of the neighborhood
    """
    
    # Default parameters
    r = 2  # radius of the neighborhood

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'radius':
            r = args[k + 1]
        else:
            raise ValueError('Invalid parameter specified')
        k += 2

    # Convert the outliers mask to a vector of coordinates
    H, W = Storage.outliers_map.shape
    outliers_vector = []
    number_outliers = 0
    for i in range(H):
        for j in range(W):
            if Storage.outliers_map[i, j]:
                number_outliers += 1
                outliers_vector.append((i, j))

    # Interpolate all outliers
    max_iterations = 10000
    iterations = 0
    # Repeat interpolation until all vectors pass the check or the iteration limit is reached
    while number_outliers > 0 and iterations < max_iterations:
        interpolate(Storage, outliers_vector, H, W, r)
        # Check interpolated values for outliers
        n = 0
        while n < number_outliers:
            i, j = outliers_vector[n]
            # Placeholder for outlier check logic
            # If the interpolated value is still an outlier, keep it in the list
            # Otherwise, remove it from the list
            n += 1
        iterations += 1

def interpolate(Storage, outliers_vector, H, W, r):
    """
    Interpolate the outliers using the median value of the neighborhood
    """
    for i, j in outliers_vector:
        i_min = max(i - r, 0)
        i_max = min(i + r + 1, H)
        j_min = max(j - r, 0)
        j_max = min(j + r + 1, W)
        neighborhood = Storage.vectors_map[i_min:i_max, j_min:j_max]
        Storage.vectors_map[i, j] = np.median(neighborhood, axis=(0, 1))

# Example usage
# storage = Storage()
# storage.outliers_map = np.random.randint(0, 2, (100, 100))
# storage.vectors_map = np.random.rand(100, 100, 2)
# interpolate_outliers(storage, 'radius', 3)