import numpy as np
from skimage.transform import resize

def write_flow_file(Storage, filename, *args):
    """
    write_flow_file Write vector map to .flo file
    Writes data from the Storage class. Vector map scaling is possible.

    Code taken from Github: https://github.com/seungryong/FCSS
    @InProceedings{kim2017,
    author = {Seungryong Kim and Dongbo Min and Bumsub Ham and Sangryul Jeon and Stephen Lin and Kwanghoon Sohn},
    title = {FCSS: Fully Convolutional Self-Similarity for Dense Semantic Correspondence},
    booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
    year = {2017}}
    """
    
    # Default parameters
    scaling = False

    # Parameter parser
    k = 0
    while k < len(args):
        if args[k] == 'scaling':
            scaling = True
        else:
            raise ValueError('Incorrect parameter specified')
        k += 1

    # Scale the vector field to the image size
    if scaling:
        Storage.vectors_map = resize(Storage.vectors_map, (Storage.image_1.shape[0], Storage.image_1.shape[1]), mode='reflect', anti_aliasing=True)

    TAG_STRING = 'PIEH'  # use this when WRITING the file

    # Sanity check
    if not filename:
        raise ValueError('writeFlowFile: empty filename')

    idx = filename.rfind('.')
    if idx == -1 or filename[idx:] != '.flo':
        raise ValueError(f'writeFlowFile: extension required in filename {filename}')

    # Write the .flo file
    with open(filename, 'wb') as f:
        f.write(TAG_STRING.encode('utf-8'))
        np.array(Storage.vectors_map.shape[1], dtype=np.int32).tofile(f)
        np.array(Storage.vectors_map.shape[0], dtype=np.int32).tofile(f)
        Storage.vectors_map.astype(np.float32).tofile(f)

# Example usage
# write_flow_file(Storage, 'output.flo', 'scaling')