import numpy as np
from skimage.transform import resize, warp
from scipy.ndimage import map_coordinates
from storage import Storage


def deform_images(Storage, deform_type):
    """
    deform_images Image deformation
    Performs image deformations according to the vector field of the last pass.
    """
    
    # Resize the vector field to the size of the image
    Storage.vectors_map_last_pass = resize(Storage.vectors_map_last_pass, Storage.image_1.shape, order=1, mode='reflect', anti_aliasing=True)

    # Image deformation methods
    if deform_type == 'symmetric':
        Storage.image_1 = apply_deformation(Storage.image_1, -Storage.vectors_map_last_pass / 2, order=3)
        Storage.image_2 = apply_deformation(Storage.image_2, Storage.vectors_map_last_pass / 2, order=3)
    elif deform_type == 'second':
        Storage.image_2 = apply_deformation(Storage.image_2, Storage.vectors_map_last_pass, order=0)
    else:
        raise ValueError('Unknown method specified')

def apply_deformation(image, deformation_field, order):
    """
    Apply deformation to the image using the given deformation field and interpolation order.
    """
    coords = np.meshgrid(np.arange(image.shape[1]), np.arange(image.shape[0]))
    coords = np.array(coords).astype(np.float64)
    coords[0] += deformation_field[..., 0]
    coords[1] += deformation_field[..., 1]
    return map_coordinates(image, [coords[1].ravel(), coords[0].ravel()], order=order, mode='reflect').reshape(image.shape)

# Example usage
# storage = Storage()
# storage.vectors_map_last_pass = np.random.rand(100, 100, 2)
# storage.image_1 = np.random.rand(100, 100)
# storage.image_2 = np.random.rand(100, 100)
# deform_images(storage, 'symmetric')