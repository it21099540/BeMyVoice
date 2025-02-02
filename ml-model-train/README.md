# Be My Voice

Develop a machine learning models that offers an inclusive learning platform and seamless communication for deaf 
and hard-of-hearing individuals, featuring real-time sign language translations for educational videos 
and meetings, as well as an AI-powered chatbot for personalized learning and resource navigation

## Table of Contents
1. Functions
    -  Sign to text
        -  Model 1 :  CatBoostClassifier
    -  Speech to text and Text to speech
        -  Model 1 : Whisper model
        -  Model 2 : SpeechT5 model
    -  chat bot
        -  Model 1 : Gemini chat bot
        -  Script 1: simple chat bot
2. API
3. How to Setup
4. Others

---

## 1. Functions

###  Sign to text
#### Model 1:  CatBoostClassifier

- **Dataset (Drive or GitHub URL)**: [ASL dataset 1](https://www.kaggle.com/datasets/debashishsau/aslamerican-sign-language-aplhabet-dataset )
                                    : [ASL dataset 2](https://www.kaggle.com/datasets/grassknoted/asl-alphabet)
- **Final Code (Folder URL)**: [Source Code](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/sign_to_text/sign_language_model_training.ipynb)
- **Use Technologies and Model**: Catboostclassifier, random forest classifier , LSTM
- **Model Label**: 0: '0', 1: '1', 2: '2', 3: '3', 4: '4', 5: '5', 6: '6', 7: '7', 8: '8', 9: '9', 10: 'A', 11: 'B', 12: 'C', 13: 'D', 14: 'DEL', 15: 'E', 16: 'F', 17: 'G', 18: 'H', 19: 'I', 20: 'J', 21: 'K', 22: 'L', 23: 'M', 24: 'N', 25: 'O', 26: 'P', 27: 'Q', 28: 'R', 29: 'S', 30: 'SPACE', 31: 'T', 32: 'U', 33: 'V', 34: 'W', 35: 'X', 36: 'Y', 37: 'Z'
- **Model Features**: point of hand
- **Model (GitHub or Drive URL)**: [All Model Folder](https://drive.google.com/drive/folders/1SNbMxdg6DPe0GOG9iQGtExX7pSDq71wV?usp=drive_link)
- **Tokenizer (GitHub or Drive URL)**: [Model File](https://drive.google.com/file/d/1Xl2Urw4E6bLdSDMlLcNSuXPTEI9DLudw/view?usp=drive_link)
- **Accuracy**:0.9533042053522666



### Speech to text and Text to speech
#### Model 1: Whisper model

- **Model documentation (Drive or GitHub URL)**: [Used pretrain model](https://github.com/openai/whisper)
- **Final Code (Folder URL)**: [Source Code](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/API/app/speech_T_text/whisper_ASR.py)
- **Use Technologies and Model**: Transfomer
- **Model output Label**: Recognized text
- **Model (GitHub or Drive URL)**: [Model File](https://drive.google.com/drive/folders/149wlLs5R09V1VFeTLr5_VCw7HgS1eG_-?usp=drive_link)

#### Model 2: SpeechT5 model

- **Model documentation (Drive or GitHub URL)**: [Used pretrain model](https://huggingface.co/microsoft/speecht5_tts)
- **Final Code (Folder URL)**: [Source Code](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/API/app/speech_T_text/speech_to_text.py)
- **Use Technologies and Model**: Transfomer
- **Model output**: voice
- **Model (GitHub or Drive URL)**: [Model File](https://drive.google.com/drive/folders/1apB_R_TsZomiIQZSq_6x-br7btSbyjir?usp=drive_link)


### Chat bot
#### Model 1: Gemini chat bot

- **Model documentation (Drive or GitHub URL)**: [Used pretrain model](https://gemini.google.com/app)
- **Final Code (Folder URL)**: [Source Code](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/API/app/chat_bot/gemini_bot.py)
- **Use Technologies and Model**: Transfomer

#### Script 1: Simple chat bot

- **Use simple script to do this type of chat bot.Add the data to the data.txt file for chat. This chat bot have no big knowledge . Only data.txt data known the bot** 
- **Data file (data.txt file)**: [link](https://drive.google.com/file/d/1aLOOKoeGEu-6kIb7ZVVTTOva9V93w9HR/view?usp=drive_link)
- **Final Code (Folder URL)**: [Source Code](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/API/app/chat_bot/simple_chatbot.py)
- **Use Technologies and Model**: Cosine Similarity



## 2. API

- **Use Technology**: fastAPI
- **API Folder (Drive or GitHub URL)**: [API Source Code](https://drive.google.com/drive/folders/1Gp9cswuew5bOE4f0eZHTt1TmL_qDTCcY?usp=drive_link)
- **API Folder Screenshot**: 
    - ![API Folder Screenshot](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/git_src/Screenshot%20(38).png)
- **API Testing Swagger Screenshots for All Endpoints**:
    - ![Swagger Endpoint 1](https://github.com/SilverlineIT/Be-My-Voice-ML/blob/main/git_src/Screenshot%20(39).png)

---

## 3. How to Stup

### Pre-requisites
- python 3.10.11

Follow these steps to set up your development environment for this project:

### Create a New `venv`

1. Navigate to your project directory:

   ```bash
   cd /path/to/your/project
   ```

2. Create a virtual environment:

   ```bash
   python -m venv <venv_name>
   ```

### Activate and Deactivate `venv`

- In `cmd`:

   ```bash
   <venv_name>\Scripts\activate
   ```

- In bash:

   ```bash
   source <venv_name>/Scripts/activate

   # To deactivate the virtual environment:
   deactivate
   ```

### Create, Activate & Deactivate `venv` using conda

- Use Anaconda Navigator to create a venv:

   ```bash
   # Activate the conda environment
   conda activate <venv_name>

   # To deactivate the conda environment
   conda deactivate
   ```

### Install the Dependencies

- You can also use a `requirements.txt` file to manage your project's dependencies. This file lists all the required packages and their versions.
1. Install packages from `requirements.txt`:

   ```
   pip install -r requirements.txt
   ```
    This ensures that your development environment matches the exact package versions specified in `requirements.txt`.

2. Verify installed packages:

   ```bash
   pip list
   ```
    This will display a list of packages currently installed in your virtual environment, including the ones from `requirements.txt`.




### Steps
1. Clone the repository:
    ```bash
    git clone https://github.com/username/repo.git
    ```
2. Navigate to the project directory:
    ```bash
    cd project-directory
    ```
3. Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
4. Run the application:
    ```bash
    fastapi dev main.py

## 4. Others
- Contact: Your Name 
