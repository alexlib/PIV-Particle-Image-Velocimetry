from Storage import Storage
from load_images import load_images
from preprocessing import preprocessing
from pass_function import pass_function
from peak_filter import peak_filter
from validate_outliers import validate_outliers
from replace_outliers_next_peak import replace_outliers_next_peak
from interpolate_outliers import interpolate_outliers
from subpixel_peak import subpixel_peak
from smoothing import smoothing
import os
# from show import show


# Example scenario
storage = Storage()

# Check if the current working directory is '/src', if not, change to '/src'
current_dir = os.getcwd()
if not current_dir.endswith('/src'):
    os.chdir('/home/user/Documents/repos/PIV-Particle-Image-Velocimetry/src')

load_images(storage, '../demos/SQG_00001_img1.tif', '../demos/SQG_00001_img2.tif')
preprocessing(storage)

pass_function(storage, [32, 32], [16, 16], 'type_pass', 'first', 'restriction', '1/2')
validate_outliers(storage)
interpolate_outliers(storage)
smoothing(storage)

pass_function(storage, [16, 16], [8, 8], 'type_pass', 'next', 'deform', 'symmetric')
validate_outliers(storage)
interpolate_outliers(storage)
smoothing(storage)

pass_function(storage, [8, 8], [4, 4], 'type_pass', 'next', 'deform', 'symmetric', 'double_corr', 'xy')
validate_outliers(storage, 'radius', 1, 'threshold', 0.5)
interpolate_outliers(storage, 'radius', 1)
subpixel_peak(storage)

# show(storage)

# Three-pass maximally loaded scenario (commented out)
# storage = Storage()
# load_images(storage, '.../demos/backstep_Re800_00007_img1.tif', '.../demos/backstep_Re800_00007_img2.tif')
# preprocessing(storage)
# pass_function(storage, [36, 31], [11, 17], 'type_pass', 'first', 'double_corr', 'center', 'restriction', '1/3')
# peak_filter(storage, 'threshold', 0.6)
# validate_outliers(storage, 'radius', 2, 'threshold', 1.2, 'noise', 0.6)
# replace_outliers_next_peak(storage, 'restriction', '1/3')
# interpolate_outliers(storage, 'radius', 2)
# smoothing(storage)

# pass_function(storage, [16, 16], [10, 10], 'type_pass', 'next', 'double_corr', 'xy', 'restriction', '1/2', 'deform', 'symmetric')
# peak_filter(storage)
# validate_outliers(storage)
# replace_outliers_next_peak(storage)
# interpolate_outliers(storage)
# smoothing(storage)

# pass_function(storage, [8, 8], [4, 4], 'type_pass', 'next', 'restriction', '1/2', 'deform', 'second')
# peak_filter(storage)
# validate_outliers(storage)
# replace_outliers_next_peak(storage)
# interpolate_outliers(storage)
# subpixel_peak(storage, 'method', 'centroid')

# show(storage)

# One-pass minimal scenario (commented out)
# storage = Storage()
# load_images(storage, '.../demos/VortexPair_1.tif', '.../demos/VortexPair_2.tif')
# preprocessing(storage)
# pass_function(storage, [48, 48], [32, 32], 'type_pass', 'first')
# show(storage)
