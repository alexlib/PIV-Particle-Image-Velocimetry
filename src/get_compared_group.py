import os
import numpy as np
from skimage import io


def get_compared_group(Storage, folder_address, image_format, processing_vec):
    """
    get_compared_group Compare the given vector field with processing results
    Finds the root mean square deviation modulus of two fields and the maximum deviation
    """
    
    # Read addresses of flow files and images from the directory
    flow_files = [f for f in os.listdir(folder_address) if f.endswith('.flo')]
    image_files = [f for f in os.listdir(folder_address) if f.endswith(image_format.split('.')[-1])]

    # Number of flow files
    N = len(flow_files)
    # Number of scenarios
    P = len(processing_vec)
    # Initialize output data
    data = np.zeros((N, P, 2))

    for n in range(N):
        # Load images
        image_address_1 = os.path.join(folder_address, image_files[2*n])
        image_address_2 = os.path.join(folder_address, image_files[2*n + 1])
        load_images(Storage, image_address_1, image_address_2)
        
        # Load the original (comparison) field
        flow_address = os.path.join(folder_address, flow_files[n])
        read_flow_file(Storage, flow_address)
        true_map = Storage.vectors_map
        
        # Run scenarios and compare fields
        for p in range(P):
            # Run scenario
            processing_vec[p](Storage)
            result_map = Storage.vectors_map
            
            # Calculate the deviation matrix by modulus
            H, W, B = result_map.shape
            div_map = np.zeros((H, W, B))
            for i in range(H):
                for j in range(W):
                    for c in range(2):
                        div_map[i, j, c] = abs(result_map[i, j, c] - true_map[Storage.centers_map[i, j, 1], Storage.centers_map[i, j, 0], c])
            
            # Calculate root mean square deviation and maximum deviation
            rms_deviation = np.sqrt(np.mean(div_map**2))
            max_deviation = np.max(div_map)
            
            # Store results
            data[n, p, 0] = rms_deviation
            data[n, p, 1] = max_deviation

    return data

# Example usage
# storage = Storage()
# folder_address = 'path/to/folder'
# image_format = '*.tif'
# processing_vec = [processing_1, processing_2, processing_3, processing_4, processing_5]
# data = get_compared_group(storage, folder_address, image_format, processing_vec)
