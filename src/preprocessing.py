import numpy as np
from skimage.color import rgb2gray

class Storage:
    def __init__(self, src_image_1, src_image_2):
        self.src_image_1 = src_image_1
        self.src_image_2 = src_image_2
        self.image_1 = None
        self.image_2 = None

def preprocessing(Storage):
    """
    preprocessing Image preprocessing
    Converts color images to grayscale and converts them to double data type.
    Assumes that the source images are the same size.
    """
    
    size_image = Storage.src_image_1.shape

    # Convert color images to grayscale and store in the Storage class
    if len(size_image) == 3 and size_image[2] > 1:
        Storage.image_1 = rgb2gray(Storage.src_image_1)
        Storage.image_2 = rgb2gray(Storage.src_image_2)
    else:
        Storage.image_1 = Storage.src_image_1
        Storage.image_2 = Storage.src_image_2

    # Convert to double data type
    if not np.issubdtype(Storage.image_1.dtype, np.float64):
        Storage.image_1 = Storage.image_1.astype(np.float64)
        Storage.image_2 = Storage.image_2.astype(np.float64)

# Example usage
# src_image_1 = np.random.rand(100, 100, 3) * 255  # Example image
# src_image_2 = np.random.rand(100, 100, 3) * 255  # Example image
# storage = Storage(src_image_1, src_image_2)
# preprocessing(storage)