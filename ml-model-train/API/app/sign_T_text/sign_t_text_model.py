import os
import numpy as np
import joblib
from keras.models import load_model
import cv2
from typing_extensions import final
from joblib import dump, load
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
from catboost import CatBoostClassifier




current_path =os.path.dirname(os.path.abspath(__file__))


# Load the model from the file
sign_rf_model = joblib.load(os.path.join(current_path,"model/RF/random_forest_modelxyz1_1.joblib"))
sign_CatBC_model = joblib.load(os.path.join(current_path,"model/GBC/CatBC_model_XYZ.joblib"))


classes={0: '0', 1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6', 7: '7', 8: '8', 9: '9', 10: 'A', 11: 'B',
        12: 'C', 13: 'D', 14: 'DEL', 15: 'E', 16: 'F', 17: 'G', 18: 'H', 19: 'I', 20: 'J', 21: 'K',
        22: 'L', 23: 'M', 24: 'N', 25: 'O', 26: 'P', 27: 'Q', 28: 'R', 29: 'S', 30: 'SPACE', 31: 'T',
        32: 'U', 33: 'V', 34: 'W', 35: 'X', 36: 'Y', 37: 'Z'}





def rf_model(input_list):

  predict=sign_rf_model.predict([input_list])
  #print(predict[0][0])

  return classes[predict[0][0]]



def CatBC_model(input_list):

  predict=sign_CatBC_model.predict([input_list])
  #print(predict[0][0])

  return classes[predict[0][0]]



""" # Load the model from the file
sign_rf_scaled_model = joblib.load(os.path.join(current_path,"model/RF_scaled/random_forest_model_scaled_XYZ.joblib"))

def rf_scaled_model(input_list):
  # Create and fit the MinMaxScaler
  scaler_xy = MinMaxScaler(feature_range=(30, 270))
  scaler_z = MinMaxScaler(feature_range=(-20,20))


  data_x = np.array(input_list[:21]).reshape(-1, 1)
  data_y = np.array(input_list[21:42]).reshape(-1, 1)
  data_z = np.array(input_list[42:]).reshape(-1, 1)

  # Create and fit the MinMaxScaler
  scaled_x = scaler_xy.fit_transform(data_x)
  scaled_x = scaled_x.flatten().tolist()

  # Create and fit the MinMaxScaler
  scaled_y = scaler_xy.fit_transform(data_y)
  scaled_y = scaled_y.flatten().tolist()

  # Create and fit the MinMaxScaler
  scaled_z = scaler_z.fit_transform(data_z)
  scaled_z = scaled_z.flatten().tolist()

  final_list=[]
  final_list.extend(scaled_x)
  final_list.extend(scaled_y)
  final_list.extend(scaled_z)

  #print(final_list)
  #predict=sign_rf_scaled_model.predict([input_list])
  predict=sign_rf_model.predict([input_list])
  #print(classes[predict[0]])

  return classes[predict[0]]


# Load the model
sign_LSTM_model = load_model(os.path.join(current_path,"model/LSTM2/sign_language_2.hdf5"))

classes_2=['0' ,'1', '2' ,'3', '4', '5' ,'6' ,'7' ,'8', '9', 'A' ,'B', 'C', 'D' ,'DEL', 'E' ,'F', 'G',
  'H' ,'I' ,'J' ',K' ,'L' ,'M' ,'N' ,'O' ,'P' ,'Q' ,'R', 'S', 'SPACE', 'T', 'U', 'V' ,'W',
  'X' ,'Y' ,'Z']


def LSTM_model(input_list,tresh=0.5):

  list_pre = np.expand_dims(input_list, axis=0)
  list_pre = np.expand_dims(list_pre, axis=-1)

  predict=sign_LSTM_model.predict(list_pre)
  #print(predict)

  pred=zip(classes_2,predict[0])
  pre_dict = dict(pred)
  final_dict={}

  for i in range(len(pre_dict)):
    if list(pre_dict.values())[i] >= tresh:
      final_dict[list(pre_dict.keys())[i]]=list(pre_dict.values())[i]
    else:
      pass

  #print(final_dict)
  if final_dict is not None:
    # Sort the dictionary by values
    sorted_dict = dict(sorted(final_dict.items(), key=lambda item: item[1],reverse=True))
    #print(list(sorted_dict.items())[0])
    return list(sorted_dict.items())
  else:
    return None


# Load the model
sign_CNN_model = load_model(os.path.join(current_path,"model/CNN_sign_language/CNN_sign_language.hdf5"))

classes_3=['A', 'B', 'C' ,'D' ,'E' ,'F', 'G' ,'H' ,'I', 'J' ,'K' ,'L' ,'M', 'N' ,'O' ,'P', 'Q' ,'R',
 'S' ,'T' ,'U' ,'V' ,'W' ,'X' ,'Y' ,'Z' ,'del' ,'space']

def CNN_model(image,tresh=0.01):
  input_shape = (224, 224, 3)

  #image=cv2.imread(image_path)
  # Resize, scale and reshape image before making predictions
  resized = cv2.resize(image, (224,224))
  resized = (resized / 255.0).reshape(-1,input_shape[1],input_shape[0],input_shape[2])
  #cv2_imshow((resized[0] * 255).astype(np.uint8))

  predict=sign_CNN_model.predict(resized)
  #print(predict)

  pred=zip(classes_3,predict[0])
  pre_dict = dict(pred)
  final_dict={}

  for i in range(len(pre_dict)):
    if list(pre_dict.values())[i] >= tresh:
      final_dict[list(pre_dict.keys())[i]]=list(pre_dict.values())[i]
    else:
      pass

  #print(final_dict)
  if final_dict is not None:
    # Sort the dictionary by values
    sorted_dict = dict(sorted(final_dict.items(), key=lambda item: item[1],reverse=True))
    #print(list(sorted_dict.items()))
    return list(sorted_dict.items())
  else:
    return None
  


from tensorflow.keras.models import load_model
import pandas as pd
from sklearn.preprocessing import MinMaxScaler
import numpy as np


# Load the model
sign_LSTM_Scaled_model = load_model(os.path.join(current_path,'model/LSTM_scaled/sign_language_2.hdf5'))



def LSTM_Scaled_model(input_list,tresh=0.005):

  # Create and fit the MinMaxScaler
  scaler_xy = MinMaxScaler(feature_range=(0,300))
  scaler_z = MinMaxScaler(feature_range=(-100,100))


  data_x = np.array(input_list[:21]).reshape(-1, 1)
  data_y = np.array(input_list[21:42]).reshape(-1, 1)
  data_z = np.array(input_list[42:]).reshape(-1, 1)

  # Create and fit the MinMaxScaler
  scaled_x = scaler_xy.fit_transform(data_x)
  scaled_x = scaled_x.flatten().tolist()

  # Create and fit the MinMaxScaler
  scaled_y = scaler_xy.fit_transform(data_y)
  scaled_y = scaled_y.flatten().tolist()

  # Create and fit the MinMaxScaler
  scaled_z = scaler_z.fit_transform(data_z)
  scaled_z = scaled_z.flatten().tolist()

  final_list=[]
  final_list.extend(scaled_x)
  final_list.extend(scaled_y)
  final_list.extend(scaled_z)

  list_pre = np.expand_dims(final_list, axis=0)
  list_pre = np.expand_dims(list_pre, axis=-1)

  predict=sign_LSTM_Scaled_model.predict(list_pre)
  # Get the index of the maximum value
  
  max_index = np.argmax(predict)
  print(max_index)
  if max_index in range(0,len(classes_2)):
    return classes_2[max_index]
  else:
    pass
 """


