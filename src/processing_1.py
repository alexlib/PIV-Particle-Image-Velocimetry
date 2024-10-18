from preprocessing import preprocessing
from pass_function import pass_function
from validate_outliers import validate_outliers
from interpolate_outliers import interpolate_outliers
from subpixel_peak import subpixel_peak
from Storage import Storage


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
storage = Storage()
processing_1(storage)