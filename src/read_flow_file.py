import numpy as np

def read_flow_file(Storage, filename):
    """
    read_flow_file Read vector map from .flo file
    Reads data from the file and writes it to the Storage class.

    Code taken from Github: https://github.com/seungryong/FCSS
    @InProceedings{kim2017,
    author = {Seungryong Kim and Dongbo Min and Bumsub Ham and Sangryul Jeon and Stephen Lin and Kwanghoon Sohn},
    title = {FCSS: Fully Convolutional Self-Similarity for Dense Semantic Correspondence},
    booktitle = {Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), IEEE},
    year = {2017}}
    """
    
    TAG_FLOAT = 202021.25  # check for this when READING the file

    # Sanity check
    if not filename:
        raise ValueError('readFlowFile: empty filename')

    if not filename.endswith('.flo'):
        raise ValueError(f'readFlowFile: filename {filename} should have extension ".flo"')

    try:
        with open(filename, 'rb') as f:
            tag = np.fromfile(f, np.float32, count=1)[0]
            width = np.fromfile(f, np.int32, count=1)[0]
            height = np.fromfile(f, np.int32, count=1)[0]

            # Sanity check
            if tag != TAG_FLOAT:
                raise ValueError(f'readFlowFile({filename}): wrong tag (possibly due to big-endian machine?)')

            if width < 1 or width > 99999:
                raise ValueError(f'readFlowFile({filename}): illegal width {width}')

            if height < 1 or height > 99999:
                raise ValueError(f'readFlowFile({filename}): illegal height {height}')

            # Read the flow data
            flow_data = np.fromfile(f, np.float32, count=2 * width * height)
            flow_data = np.resize(flow_data, (height, width, 2))

            # Store the data in the Storage class
            Storage.vectors_map = flow_data

    except IOError:
        raise ValueError(f'readFlowFile: could not open {filename}')

# Example usage
# storage = Storage()
# read_flow_file(storage, 'path/to/your/file.flo')