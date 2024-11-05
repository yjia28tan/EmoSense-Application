# Facial Emotion Recognition (FER) Model Training
This repository contains the code and resources for training a Facial Emotion Recognition (FER) model using the FER2013 dataset. The final model is designed to detect four primary emotions (happy, sad, angry, neutral) from grayscale facial images, based on deep learning techniques using convolutional neural networks (CNNs).

## Final model 
The final model achieved an accuracy of 75.21% and was trained by RestNet50 using the Jupyter notebook file: train_resnet_72.ipynb.

Download the FER model:
[RestNet50 FER model](https://drive.google.com/file/d/122epRv2JVvB4ziQtrn82qWKVhaHi3CNc/view?usp=sharing) <br/><br/>
Model Validation Accuracy: 75.21% <br/>
Model Validation Loss: 0.62



## Dataset
The model is trained on the FER2013 dataset, which consists of 48x48 pixel grayscale images of faces. The dataset contains 35,887 images across seven emotion classes: Angry, Disgust, Fear, Happy, Sad, Surprise, and Neutral.

For this project, the Disgust and Fear categories were removed due to their low representation and ambiguity. The final classes used are:
   - Happy
   - Sad
   - Angry
   - Neutral


The dataset is available on Kaggle: [Kaggle FER2013](https://www.kaggle.com/datasets/msambare/fer2013)


## Requirements
The following packages are required to run the training scripts:
   - Python 3.8+
   - TensorFlow
   - Keras
   - NumPy
   - OpenCV
   - Scikit-learn
   - Matplotlib
