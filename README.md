
# Digital Particle Image Velocimetry (PIV)

This repository presents the implementation of the cross-correlation method for determining local displacements of optical flow. The main application areas are the measurement of liquid and gaseous flows (PIV), measurement of solid body deformations (Digital Image Correlation), and reconstruction of the 3D shape of an object's surface during stereoscopic imaging (stereovision).

Directories in this Repository
demos: project demonstration with examples and accuracy measurement results <br> matlab: project code, method descriptions, and functional diagram

## Running the Project
An example of running the project can be found in the script main. Module descriptions are in the README of the matlab directory. The main script provides examples of various processing scenarios. Depending on the task, the processing workflow (scenario) can be individually assembled to form the optimal solution.

## Project Description
The main idea of this project is to create a modular foundation (skeleton) for developing custom solutions based on the cross-correlation processing method. The current implementation is less accurate than the OpenPIV project but offers more flexible configuration. OpenPIV is limited to interrogation window sizes of powers of 2 and does not allow separate parameter settings for each iteration. While this may be sufficient for most applications, the current project offers greater freedom in configuring the processing scenario, both in terms of interrogation window sizes and parameters for each iteration.

<p float="left"> <img src="/demos/VortexPair.gif" width="300" /> <img src="/demos/example_1.png" width="300" /> </p>
The project was initially intended not only for flow measurements but also for stereovision tasks. Images for the stereovision task were obtained on a stand simulating the deformation of an aircraft wing surface (or from the master's thesis, page 74, figure 36).

<p float="left"> <img src="/demos/SheetSurface.gif" width="300" /> <img src="/demos/example_2.png" width="340" /> </p>
For convenient visualization of results, a simple user interface show with various display parameters was written.

<p float="left"> <img src="/demos/example_3.png" width="640" /> </p>
Achieving accuracy comparable to OpenPIV is possible if the modules resize(multigrid), deform_images(deform), validate_outliers, interpolate, and smoothing are reworked. These methods use simple processing based on built-in functions in Matlab. This was done to simplify the understanding of the processing process in the project. The relative simplicity and modularity of the project may allow it to be used not only as a foundation (skeleton) for other solutions but also for educational purposes. An example of OpenPIV accuracy is provided in the script test_processing in the variables mean_target and max_target. Also, in the openpiv_data directory, there are examples of OpenPIV processing with visualization from both python and Matlab. The processing was carried out using a three-pass method with interrogation window deformation with window sizes of 32, 16, 8 pixels. In the README of the demos directory, a comparison of accuracy for 5 different scenarios is provided using the PIV dataset.

###  Notes
This project is not highly reliable. It is quite easy to cause an execution error, for example, by placing subpixel_peak after the smoothing method, as subpixel_peak does not process fractional displacements, or by setting the parameter ‘type_pass’ = ‘next’ in the pass method on the first pass, and so on. The project can be used as a ready-made program, but it is primarily intended for programmers who can use it as a foundation for developing their own solutions. Regarding image border processing, I decided not to extend the image for vector calculation to the border. Currently, the nearest vector to the border is at a distance of half the interrogation window of the last pass. I would appreciate reasoned criticism and advice on improving the project.