import numpy as np

def images_split(Storage, type_pass, multigrid, borders):
    """
    images_split Calculate the coordinates of the interrogation windows on the image
    Performs the calculation of the coordinates of the interrogation windows without considering the vector field.
    """
    
    if type_pass == 'first' or multigrid:  # calculate the coordinates of the interrogation windows
        image_size = Storage.image_1.shape
        
        image_size = np.array(image_size)
        window_size = np.array(Storage.window_size)
        # Number of interrogation windows horizontally and vertically
        field_shape = np.floor((image_size - window_size) / (window_size - Storage.overlap)) + 1
        
        # Size of the area covered by the interrogation windows
        w = field_shape[1] * (Storage.window_size[1] - Storage.overlap[1]) + Storage.overlap[1]
        h = field_shape[0] * (Storage.window_size[0] - Storage.overlap[0]) + Storage.overlap[0]
        
        # Residual boundaries not covered by the interrogation windows
        remainder = [image_size[0] - h, image_size[1] - w]
        
        # Residual boundaries in the upper left part of the image
        x_left_remainder = np.floor(remainder[1] / 2) + 1
        y_top_remainder = np.floor(remainder[0] / 2) + 1
        
        # Size of the centered area covered by the interrogation windows
        search_area_size = [x_left_remainder, y_top_remainder, w, h]
        
        # Calculate the centers of the interrogation windows
        if (Storage.window_size[1] - Storage.overlap[1]) > 1:  # for overlap greater than one pixel
            x = np.arange(search_area_size[0] + np.ceil(Storage.window_size[1] / 2) - 1, 
                          search_area_size[0] + search_area_size[2] - np.ceil(Storage.window_size[1] / 2) + 1, 
                          Storage.window_size[1] - Storage.overlap[1])
            y = np.arange(search_area_size[1] + np.ceil(Storage.window_size[0] / 2) - 1, 
                          search_area_size[1] + search_area_size[3] - np.ceil(Storage.window_size[0] / 2) + 1, 
                          Storage.window_size[0] - Storage.overlap[0])
        else:  # for overlap equal to one pixel
            x = np.arange(search_area_size[0] + np.ceil(Storage.window_size[1] / 2) - 1, 
                          search_area_size[0] + search_area_size[2] - np.ceil(Storage.window_size[1] / 2), 
                          Storage.window_size[1] - Storage.overlap[1])
            y = np.arange(search_area_size[1] + np.ceil(Storage.window_size[0] / 2) - 1, 
                          search_area_size[1] + search_area_size[3] - np.ceil(Storage.window_size[0] / 2), 
                          Storage.window_size[0] - Storage.overlap[0])
        
        # Add interrogation windows at the borders of the image for full coverage
        if borders:
            if remainder[0] != 0:
                if remainder[0] == 1:  # if the residual boundary is one pixel
                    y = np.append(y, y[-1] + np.floor(remainder[0] / 2) + np.mod(remainder[0], 2))
                else:
                    y = np.append(np.insert(y, 0, y[0] - np.floor(remainder[0] / 2)), y[-1] + np.floor(remainder[0] / 2) + np.mod(remainder[0], 2))
            if remainder[1] != 0:
                if remainder[1] == 1:  # if the residual boundary is one pixel
                    x = np.append(x, x[-1] + np.floor(remainder[1] / 2) + np.mod(remainder[1], 2))
                else:
                    x = np.append(np.insert(x, 0, x[0] - np.floor(remainder[1] / 2)), x[-1] + np.floor(remainder[1] / 2) + np.mod(remainder[1], 2))
        
        X0, Y0 = np.meshgrid(x, y)
        return X0, Y0

# Example usage
# storage = Storage()
# storage.image_1 = np.random.rand(100, 100)
# storage.window_size = np.array([32, 32])
# storage.overlap = np.array([16, 16])
# X0, Y0 = images_split(storage, 'first', True, True)