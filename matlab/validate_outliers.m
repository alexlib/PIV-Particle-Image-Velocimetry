import numpy as np
from scipy.ndimage import median_filter

def validate_outliers(Storage, *args):
    """
    validate_outliers Check for outliers using the normalized median method
    It is possible to check one specific vector for an outlier, as well as set your own calculation parameters.
    """
    
    # Default parameter definitions
    r = 2  # radius of the neighborhood of the central point (usually set to 1 or 2)
    threshold = 2  # fluctuation threshold (usually around 2)
    noise = 0.5  # calculated noise level during measurement (in pixels)
    borders = True  # whether to check borders
    single = False  # check one specific vector

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'radius':
            r = args[k + 1]
        elif args[k] == 'threshold':
            threshold = args[k + 1]
        elif args[k] == 'noise':
            noise = args[k + 1]
        elif args[k] == 'borders':
            borders = args[k + 1]
        elif args[k] == 'single':
            single = True
            i_single = args[k + 1][0]
            j_single = args[k + 1][1]
        else:
            raise ValueError('Incorrect parameter specified')
        k += 2

    # Size of the vector map
    H, W = Storage.vectors_map.shape[:2]
    # Normalized fluctuations relative to the neighborhood
    NormFluct = np.zeros((H, W, 2))
    # Neighborhood with the central point
    Neigh = np.zeros((2 * r + 1, 2 * r + 1))
    # Convert to column vector
    NeighCol = Neigh.flatten()
    # Neighborhood excluding the central point
    NeighColEx = np.concatenate((NeighCol[:(2 * r + 1) * r + r], NeighCol[(2 * r + 1) * r + r + 1:]))

    # The rest of the function implementation goes here
    # ...

# Example usage
# validate_outliers(Storage, 'radius', 3, 'threshold', 2.5, 'noise', 0.4, 'borders', False, 'single', [1, 2])