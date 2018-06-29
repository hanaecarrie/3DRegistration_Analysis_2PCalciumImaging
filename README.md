# Registration and Analysis of 3D 2-photon recordings in awake mice

3DRegistration_Analysis_2PCalciumImaging contains my 6-month internship coding development done at the Andermann Lab in 2018.

This package can be used to register 3D imaging sessions (runs) of 30min acquired at 15.5Hz (so about 28 000 frames) of images of type uint16 saved as .sbx (scanbox) files on the lab servers (>= 160GB of RAM).


## Getting Started

NB: This code development is not an independant package since:
* it requires functions from other user folders in the code Dropbox
* it contains hardcoded paths to the lab servers
* it contains harcorded paths to the ImageJ application version used in the lab
Thus, this package is dedicated to lab users only.

For lab users:
* make sure that MATLAB is correcly installed on your session so that parallelization can be performed successfully.
* in MATLAB, go to Preferences -> General -> Java Heap Memory, and turn the Java Heap size to its maximum. Otherwise, problems will appear when calling ImageJ from MATLAB.


### Testing

This package has been used and tested on Magatron and Santiago servers.


### Further perspectives

* load the data by chunks to allow registration of bigger files with less RAM


## Author

* **Hanaé Carrié** 


## Acknowledgments

* Arthur Sugden, PhD
* Alex Fratzl
* Fred Shipley
* The Andermann Lab, directed by Mark Andermann (PhD)


