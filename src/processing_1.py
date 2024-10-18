import numpy as np


def processing_1(Storage):
    """
    Single-pass scenario
    """
    
    preprocessing(Storage)

    pass_function(Storage, [32, 32], [24, 24], 'type_pass', 'first', 'restriction', '1/3')
    validate_outliers(Storage)
    interpolate_outliers(Storage)
    subpixel_peak(Storage)

# Example usage
# storage = Storage()
# processing_1(storage)