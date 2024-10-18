import numpy as np
from skimage.transform import resize

def resize_field(Storage, size_map):
    """
    resize_field Resizing the vector field
    Performs resizing of the vector field according to the new
    dimensions and overlap of the interrogation windows.
    """
    
    # Resizing method
    Storage.vectors_map = resize(Storage.vectors_map, size_map, mode='reflect', anti_aliasing=True)

# Example usage
# storage = Storage()
# resize_field(storage, (200, 200))
