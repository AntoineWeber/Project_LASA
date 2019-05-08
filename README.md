# A fast decode of grasping intention from the muscular activity

The goal of this project was to predict the grasping intention in the early stages of the reaching motion
using 8 differential EMG channels. Reach-to-grasp motions were assessed using two different grasp types :
the Thumb-2 fingers grasp type (the object is lifted using only the thumb, the index and the middle finger)
and the power grasp type (with all the fingers). On the other side, the reach-not-to-grasp motions were assessed
using a single grasp type being simply the no-grasp type (the hand reaches the object but do not grasp it).

## Methods

Different classifiers were used to predict the grasping intention. The implemented classifiers are an Echo State Network, a Linear Discriminant Analysis, a C-Support Vector Machine and finally a Gaussian Mixture Model.

## Structure
The code was written on MATLAB2018a.
It can be found in the [First_Approach](SemProject_AW/Second_Data/First_Approach) and [Second_Approach](SemProject_AW/Second_Data/Second_Approach) files. As explained in the [report](fast-decode-grasping.pdf), three different approaches were performed to analyse the data. The first two are implementend in the first folder, the third one on the second folder.

To correctly run the code, one should first run the *main* file of the specific approach to be tested. It will load the raw data and process it accordingly to the given approach. The directory should always remain the same, being the *SemesterProject* folder.
After the run of the main file, a new .mat file will be saved containing the data to be processed. From here, the different analysis being the ESN, LDA, SVM and GMM functions can be runned directly.

More specific definitions are inside the [info](SemProject_AW/info.txt) file.


## Author

* **Antoine Weber** 

## Remarks

The dataset is not given for confidential reasons. <br>
