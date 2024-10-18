import numpy as np

def processing_2(Storage):
    """
    Three-pass scenario
    """
    
    preprocessing(Storage)

    pass_function(Storage, [32, 32], [16, 16], 'type_pass', 'first')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    smoothing(Storage)

    pass_function(Storage, [16, 16], [8, 8], 'type_pass', 'next')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    smoothing(Storage)

    pass_function(Storage, [8, 8], [4, 4], 'type_pass', 'next', 'double_corr', 'xy')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    subpixel_peak(Storage)

# Example usage
# storage = Storage()
# processing_2(storage)