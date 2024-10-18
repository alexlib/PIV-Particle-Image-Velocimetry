import numpy as np

def double_correlate(Storage, direct):
    """
    double_correlate Multiply neighboring correlation maps
    Performs multiplication of neighboring correlation maps using different methods.
    """
    
    # Multiplication methods
    if direct == 'x':
        direct_x(Storage)  # multiply with the right correlation map
    elif direct == 'y':
        direct_y(Storage)  # multiply with the bottom correlation map
    elif direct == 'xy':
        direct_xy(Storage)  # multiply with the right and bottom correlation maps
    elif direct == 'center':
        direct_center(Storage)  # multiply with 4 neighboring correlation maps
    else:
        raise ValueError('Unknown method')

def direct_x(Storage):
    """
    Multiply with the right correlation map
    For the rightmost column, multiplication is not performed.
    """
    for i in range(len(Storage.correlation_maps)):
        for j in range(len(Storage.correlation_maps[0]) - 1):
            Storage.correlation_maps[i][j] *= Storage.correlation_maps[i][j + 1]

def direct_y(Storage):
    """
    Multiply with the bottom correlation map
    For the bottommost row, multiplication is not performed.
    """
    for i in range(len(Storage.correlation_maps) - 1):
        for j in range(len(Storage.correlation_maps[0])):
            Storage.correlation_maps[i][j] *= Storage.correlation_maps[i + 1][j]

def direct_xy(Storage):
    """
    Multiply with the right and bottom correlation maps
    For the rightmost column and bottommost row, multiplication is not performed.
    """
    for i in range(len(Storage.correlation_maps) - 1):
        for j in range(len(Storage.correlation_maps[0]) - 1):
            Storage.correlation_maps[i][j] *= Storage.correlation_maps[i + 1][j] * Storage.correlation_maps[i][j + 1]

def direct_center(Storage):
    """
    Multiply with 4 neighboring correlation maps
    For the rightmost column, bottommost row, and their intersections, multiplication is not performed.
    """
    for i in range(1, len(Storage.correlation_maps) - 1):
        for j in range(1, len(Storage.correlation_maps[0]) - 1):
            Storage.correlation_maps[i][j] *= (Storage.correlation_maps[i + 1][j] * Storage.correlation_maps[i - 1][j] *
                                               Storage.correlation_maps[i][j + 1] * Storage.correlation_maps[i][j - 1])

# Example usage
# storage = Storage()
# double_correlate(storage, 'x')