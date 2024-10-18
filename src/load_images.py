from imageio import imread

def load_images(Storage, image_address_1, image_address_2):
    """
    load_images Load images into the Storage class
    Supports formats: jpg, jpeg, png, tif
    """
    Storage.src_image_1 = imread(image_address_1)
    Storage.src_image_2 = imread(image_address_2)

# Example usage
# storage = Storage()
# load_images(storage, 'path/to/image1.jpg', 'path/to/image2.png')