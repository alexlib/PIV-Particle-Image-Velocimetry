
# Документация проекта
# Project Documentation
Here is the informal documentation of the code and a functional flowchart.
The sequence of using the modules (methods) is not strict, it is possible to use them in a different order. This is only a recommendation for the sequence of modules.

<img src="/demos/FunctionSchema.png" width="400" />|<img src="/demos/FunctionSchemaAdd.png" width="300" /> 
|:--------------------------------------------------|-----------------------------------------------------:|

Module Descriptions: <br>
**1.** `Storage` <br>
Data storage class. It facilitates interaction and data transfer between functions. <br>
Properties (fields): <br>
`src_image_1` – first source image <br>
`src_image_2` – second source image <br>
`image_1` – first processed image <br>
`image_2` – second processed image <br>
`window_size` – interrogation window size `[height, width]` <br>
`overlap` – overlap size of interrogation windows `[height, width]` <br>
`centers_map` – matrix of interrogation window centers on the first image <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`X = centers_map( : , : ,1)`; (columns `j`) <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`Y = centers_map( : , : ,2)`; (rows `i`) <br>
`vectors_map` – vector field <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`U = vectors_map( : , : ,1)` <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`V = vectors_map( : , : ,2)` <br>
`outliers_map` – outlier mask <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`0` – no outlier <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`1` – outlier <br>
`replaces_map` – replaced vectors mask <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`0` – vector not replaced <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`1` – interpolated <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`2` – replaced by 2nd correlation peak <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`3` – replaced by 3rd correlation peak <br>
`correlation_maps` – collection storing correlation maps <br>
&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;`corr_map = correlation_maps{i, j}` <br>
`vectors_map_last_pass` – vector field of the last pass <br>

**2.** `load_images(Storage, image_address_1, image_address_2)` <br>
Loads a pair of images into the `Storage` class. Supported formats are **jpg, jpeg, png, tif**.

**3.** `preprocessing(Storage)` <br>
Image preprocessing. Converts color images to grayscale and converts to **double** data type. Writes the preprocessed images to the `Storage` class.

**4.** `pass(Storage, window_size, overlap, varargin)` <br>
Calculates the vector field using the cross-correlation method. Depending on the specified parameters, it can work as a pass to obtain the primary vector field or as a pass to refine the existing vector field. <br>

| `varargin`                                                                                                                                                                  |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `‘type_pass’` – pass type <br> `type_pass` = `‘first’` or `‘next’`                                                                                                          |
| `‘double_corr’` = `true/false` – multiplication of neighboring correlation maps <br> `direct` = `‘x’`, `‘y’`, `‘xy’`, `‘center’` – multiplication method                    |
| `‘restriction’` = `true/false` – restriction of the search area for the correlation peak <br> `restriction_area` = `‘1/4’`, `‘1/3’`, `‘1/2’` – restriction size relative to window size |
| `‘deform’` = `true/false` – image deformation <br> `deform_type` = `‘symmetric‘` or `‘second’` – deformation type                                                          |
| `‘borders’` – image border processing <br> `borders` = `true/false`                                                                                                        |

Main tasks are to split the images into interrogation windows, perform cross-correlation of the interrogation windows, and find the cross-correlation maxima. <br>
Options: <br>
- Multigrid method (`multigrid`), enabled if the window size (`windows_size`) or overlap (`overlap`) of the interrogation windows is changed relative to the previous pass. <br>
- Image deformation (interrogation windows) (`deform`). <br>
- Multiplication of neighboring correlation maps (`double_corr`) to reduce noise influence. <br>
- Restriction of the search area for the correlation peak (`restriction`) to reduce the number of erroneous vectors, but at the cost of the maximum resolvable displacement vector magnitude. <br>
- Processing, including image borders (`borders`). <br>

**4.1** `[X0, Y0] = images_split(Storage, type_pass, multigrid, borders)` <br>
Calculates the coordinates of the interrogation windows without considering the vector field. <br>
If `type_pass = ‘first’` or `multigrid = true`, the coordinates of the interrogation windows are calculated.
Otherwise, the output arguments are assigned values from the previous pass (`Storage.centers_map`). <br>
`[X0, Y0]` – coordinates of the top-left corner of the interrogation windows on the first image. <br>
The `borders` parameter allows filling the residual borders with interrogation windows if the number of windows fitting the image size is not an integer multiple. In this case, the boundary interrogation windows will have a different overlap size (`overlap`).

**4.2** `deform_images(Storage, deform_type)` <br>
Deforms the images according to the vector field of the last pass. <br>
There are two types of deformation: <br>
`‘symmetric’` – both images are deformed symmetrically towards each other; <br>
`‘second’` – only the second image is deformed towards the first image.

**4.3** `resize_field(Storage, size_map)` <br>
Scales the vector field from the previous pass according to the new sizes (`windows_size`) and overlap (`overlap`) of the interrogation windows.

**4.4** `cross_correlate(Storage, size_map, X0, Y0, type_pass, deform, double_corr)` <br>
Cross-correlation of the interrogation windows. Uses the built-in ***Matlab*** function `normxcorr2`. <br>
If `type_pass = ‘first’` or `deform = true`, the interrogation windows on the second image are not shifted relative to the first. Otherwise, the interrogation windows on the second image are shifted according to the vector field (`Storage.vectors_map`). If the interrogation windows on the second image go beyond the image boundaries, they are shifted inside to the image boundary. <br>
Added error handling for the `normxcorr2` function
`‘images:normxcorr2:sameElementsInTemplate’`, which occurs in the case of uniformity of the interrogation window, i.e., identical brightness in all pixels within the interrogation window. In such a case, the displacement vector belonging to the interrogation window is recorded as an outlier, and the correlation map is filled with zeros or, if the option of multiplying neighboring correlation maps (`double_corr`) is selected, with ones.

**4.5** `double_correlate(Storage, direct)` <br>
Multiplication of neighboring correlation maps. Reduces random noise on the correlation maps. Effective in the case of small deviations of neighboring vectors.

**4.6** `search_peak(Storage, size_map, restriction, restriction_area)` <br>
Search for the correlation peak (maximum), which is the displacement vector. For outliers identified in the `cross_correlate` function, the displacement vector is set to zero.

**5.** `[varargout] = peak_filter(Storage, varargin)` <br>
Outlier check based on the correlation peak magnitude. <br>
It is possible to check a single vector by its coordinates.

| `varargin`                                                                                                   |
|:-------------------------------------------------------------------------------------------------------------|
| `‘threshold’` – filtering threshold <br> `threshold` = `(double)`                                             |
| `‘single’` = `true/false` – check a single vector <br> `[i ,j]` = `[(int),(int)]` – vector coordinates        |

`varargout` = `true/false` – in case of checking a single vector.

**6.** `[varargout] = validate_outliers(Storage, varargin)` <br>
Outlier detection using the normalized median test. <br>
It is possible to check a specific vector and set custom calculation parameters.

| `varargin`                                                                                                  |
|:------------------------------------------------------------------------------------------------------------|
| `‘radius’` – neighborhood radius <br> `r` = `(int)`                                                          |
| `‘threshold’` – fluctuation threshold <br> `threshold` = `(double)`                                          |
| `‘noise’` – noise level in measurements <br> `noise` = `(double)`                                            |
| `‘borders’` – field border check <br> `borders` = `true/false`                                               |
| `‘single’` = `true/false` – check a single vector <br> `[i ,j]` = `[(int),(int)]` – vector coordinates       |

`varargout` = `true/false` – in case of checking a single vector.

**7.** `replace_outliers_next_peak(Storage, varargin)` <br>
Replacement of outliers with the 2nd and 3rd correlation peaks. <br>
It is possible to set a restriction on the search area for the correlation peak.

| `varargin`                                                                                                                                                                  |
|:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `‘restriction’` = `true/false` – restriction of the search area for the correlation peak <br> `restriction_area` = `‘1/4’`, `‘1/3’`, `‘1/2’` – restriction size relative to window size |

First, all outliers are replaced with the 2nd correlation peak and the replaced vectors are checked using the normalized median test (`validate_outliers`). If some vectors are still outliers, they are replaced with the 3rd correlation peak and checked again. Those that fail the check are reverted to their original state. In case of replacement with the 2nd correlation peak, the value `2` is recorded in the replaced vectors mask (`Storage.replaces_map`), and in case of the 3rd peak, the value `3`: <br>
`Storage.replaces_map(i, j) = 2`, <br>
`Storage.replaces_map(i, j) = 3`.

**8.** `interpolate_outliers(Storage, varargin)` <br>
Replacement of outliers with the median value of the neighborhood.

| `varargin`                                        |
|:--------------------------------------------------|
| `‘radius’` – neighborhood radius <br> `r` = `(int)`|

Interpolation is repeated until all replaced vectors pass the normalized median test (`validate_outliers`) or the iteration limit is reached. In case of successful replacement, the value `1` is recorded in the replaced vectors mask (`Storage.replaces_map`): <br>
`Storage.replaces_map(i, j) = 1`.

**9.** `smoothing(Storage)` <br>
Smoothing of the vector field. Improves the smoothness of the vector field. <br>
Not recommended for use in the final pass and before subpixel refinement (`subpixel_peak`).

**10.** `subpixel_peak(Storage, varargin)` <br>
Refinement of the correlation peak with subpixel accuracy.

| `varargin`                                        |
|:--------------------------------------------------|
| `‘method’` – three-point approximation method <br> `method` = `‘gaussian’`, `‘centroid’`, `‘parabolic’`|

Interpolated vectors are not processed (`Storage.replaces_map = 1`).
If you want to use this method on non-integer vector field values, for example, after smoothing the vector field (`smoothing`), you need to round to the nearest integer displacement (`x_peak, y_peak`).

**11.** `show(Storage)` <br>
Visualizer of processing results.

**12.** `read_flow_file(Storage, filename)` <br>
Reads the vector map from a **.flo** file and writes it to the `Storage` class.

**13.** `write_flow_file(Storage, filename, varargin)` <br>
Writes the vector field from the `Storage` class to a **.flo** file. <br>
It is possible to scale the vector field before writing to the file.

| `varargin`                                                |
|:----------------------------------------------------------|
| `‘scaling’` = `true/false` – scaling of the vector field  |

It is recommended to use it together with the `‘scaling’` parameter, which is responsible for scaling the vector field to the image size (vector per pixel). Since the **flow** file assumes that the vector field density corresponds to the image size and therefore does not contain information about the vector origin (`Storage.centers_map`).

**14.** `main` <br>
Example of program operation with visualization of results and examples of various processing scenarios.

**15.** `processing_1(Storage), processing_2(Storage) … processing_5(Storage)` <br>
Image processing scenarios (procedures). <br>
Examples of possible procedures: <br>
`processing_1` – single-pass scenario, <br>
`processing_2` – three-pass scenario, <br>
`processing_3` – three-pass scenario with image deformation, <br>
`processing_4` – four-pass scenario, <br>
`processing_5` – four-pass scenario with image deformation.

**16.** `test_processing` <br>
Script for testing a given processing scenario on 5 pairs of images with different types of flow.

**16.1** `div_vec = get_compared(Storage, procedure, image_address_1, image_address_2, visual_map, visual_bar, varargin)` <br>
Comparison of the given vector field with the processing result. <br>
Finds the arithmetic mean of the deviation magnitude of two fields and the maximum deviation in one of the coordinates. <br>
The arithmetic mean of the deviation magnitudes is calculated by the following formula:

$$ \displaystyle\ mean = \frac{\sum [|x-x_0|+|y-y_0|]}{2\times H\times W} $$

where `H`, `W` – sizes of the vector field.

**17.** `group_test` <br>
Script for testing a group of processing scenarios on a dataset. <br>
Allows obtaining data on the root mean square and maximum deviations of vector fields for a list of processing scenarios on a dataset.
The dataset directory should contain flow files with the true field and pairs of images sorted so that they correspond to the flow files and the image pairs follow each other, an example in the directory [demos/group_test](/demos/group_test).

**17.1** `data = get_compared_group(Storage, folder_address, image_format, processing_vec)` <br>
Comparison of the given vector field with the processing results of the scenarios. <br>
Finds the root mean square of the deviation magnitude of two fields and the maximum deviation. <br>
The root mean square of the deviations is calculated by the following formula:

$$ \displaystyle\ RMS = \sqrt\frac{\sum [(x-x_0)^2+(y-y_0)^2]}{H\times W (H\times W - 1)} $$

where `H`, `W` – sizes of the vector field.

**17.2** `build_graphs_group(data)` <br>
Visualization of comparison results for all scenarios. Allows visualizing a dynamic number of scenarios.
