import numpy as np
from scipy.ndimage import median_filter

def smoothing(Storage):
    """
    smoothing Smoothing of the vector field
    Improves the smoothness of the vector field. Not recommended for use on
    the final pass and before subpixel refinement (subpixel_peak).
    """
    
    # Smoothing data using a median filter
    Storage.vectors_map = median_filter(Storage.vectors_map, size=4)
    Storage.vectors_map_last_pass = median_filter(Storage.vectors_map_last_pass, size=4)

# Example usage
# storage = Storage()
# smoothing(storage)