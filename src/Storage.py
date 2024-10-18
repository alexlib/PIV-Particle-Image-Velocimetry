class Storage:
    """
    Storage Data storage class for processing
    This is an abstract class (handle), which allows passing
    class properties by reference.
    """

    def __init__(self):
        """
        Initialization of the class
        Initialization of class properties
        """
        self.src_image_1 = None           # first source image
        self.src_image_2 = None           # second source image
        self.image_1 = None               # first processed image
        self.image_2 = None               # second processed image
        self.window_size = None           # size of the interrogation window [height, width]
        self.overlap = None               # overlap size of the interrogation windows
        self.centers_map = None           # matrix of interrogation window centers on the first image
        self.vectors_map = None           # vector field
        self.outliers_map = None          # outlier mask
        self.replaces_map = None          # mask of replaced vectors
        self.correlation_maps = None      # collection storing correlation maps
        self.vectors_map_last_pass = None # vector field of the last pass

# Example usage
# storage = Storage()