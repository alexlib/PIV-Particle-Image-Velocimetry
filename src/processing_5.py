import numpy as np
from scipy.ndimage import gaussian_filter

def processing_5(Storage):
    """
    Four-pass scenario with deformation
    """
    
    preprocessing(Storage)

    pass_function(Storage, [64, 64], [32, 32], 'type_pass', 'first', 'restriction', '1/3')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    smoothing(Storage)

    pass_function(Storage, [32, 32], [16, 16], 'type_pass', 'next', 'deform', 'symmetric')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    smoothing(Storage)

    pass_function(Storage, [16, 16], [8, 8], 'type_pass', 'next', 'deform', 'symmetric')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    smoothing(Storage)

    pass_function(Storage, [8, 8], [4, 4], 'type_pass', 'next', 'double_corr', 'xy', 'deform', 'symmetric')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    subpixel_peak(Storage)

# Example usage
# storage = Storage()
# processing_5(storage)