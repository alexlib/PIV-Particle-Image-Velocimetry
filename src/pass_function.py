from images_split import images_split
from deform_images import deform_images
from resize_field import resize_field
from cross_correlate import cross_correlate
from double_correlate import double_correlate
from search_peak import search_peak
import numpy as np


def pass_function(Storage, window_size, overlap, *args):
    """
    pass_function Calculation of the vector field by the cross-correlation method
    Performs cross-correlation of local areas (interrogation windows) on a pair
    of images. Depending on the specified parameters, it can work as
    a pass to obtain the primary vector field, or as a pass to
    refine the existing vector field.
    """
    
    # Default parameter definitions
    type_pass = 'first'       # pass type 'first' or 'next'
    double_corr = False       # multiplication of neighboring correlation maps
    direct = 'x'              # multiplication method
    restriction = False       # restriction of the search area for the correlation peak
    restriction_area = 1/2    # restriction size relative to the window size
    deform = False            # image deformation
    deform_type = 'symmetric' # deformation type
    borders = True            # image border processing

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'type_pass':
            type_pass = args[k + 1]
        elif args[k] == 'double_corr':
            double_corr = True
            direct = args[k + 1]
        elif args[k] == 'restriction':
            restriction = True
            restriction_area = args[k + 1]
            if restriction_area == '1/2':
                restriction_area = 1/2
            elif restriction_area == '1/3':
                restriction_area = 1/3
            elif restriction_area == '1/4':
                restriction_area = 1/4
            else:
                raise ValueError('Invalid parameter')
        elif args[k] == 'deform':
            deform = True
            deform_type = args[k + 1]
        elif args[k] == 'borders':
            borders = args[k + 1]
        else:
            raise ValueError('Incorrect parameter specified')
        k += 2

    # The rest of the function implementation goes here
    """
    pass_function Calculation of the vector field by the cross-correlation method
    Performs cross-correlation of local areas (interrogation windows) on a pair
    of images. Depending on the specified parameters, it can work as
    a pass to obtain the primary vector field, or as a pass to
    refine the existing vector field.
    """
    
    # Check for changes in window size and overlap
    multigrid = type_pass != 'first' and (not np.array_equal(Storage.window_size, window_size) or not np.array_equal(Storage.overlap, overlap))

    # Record new window sizes and overlap
    Storage.window_size = window_size
    Storage.overlap = overlap

    # Form coordinates of interrogation windows on the first image
    X0, Y0 = images_split(Storage, type_pass, multigrid, borders)

    # Size of the new vector field
    size_map = X0.shape

    # Deform images
    if deform:
        deform_images(Storage, deform_type)

    # Scale the vector field (multigrid)
    if multigrid:
        resize_field(Storage, size_map)

    # Calculate correlation maps
    cross_correlate(Storage, size_map, X0, Y0, type_pass, deform, double_corr)

    # Multiply neighboring correlation maps
    if double_corr:
        double_correlate(Storage, direct)

    # Search for the correlation peak
    search_peak(Storage, size_map, restriction, restriction_area)

    # Record the resulting vector field
    if type_pass == 'first':
        Storage.vectors_map = Storage.vectors_map_last_pass
    else:
        Storage.vectors_map += Storage.vectors_map_last_pass

# Example usage
# storage = Storage()
# pass_function(storage, [32, 32], [16, 16], type_pass='first', double_corr=True, direct='x', restriction=True, restriction_area=0.5, deform=True, deform_type='symmetric', borders=True)
