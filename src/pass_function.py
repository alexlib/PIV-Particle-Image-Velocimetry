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
    # ...

# Example usage
# pass_function(Storage, window_size, overlap, 'type_pass', 'next', 'double_corr', 'y', 'restriction', '1/3', 'deform', 'asymmetric', 'borders', False)