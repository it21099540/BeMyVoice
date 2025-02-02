import librosa
import torch
#import IPython.display as display
#import transformers
import numpy as np
import os
import nltk
import torchaudio
import soundfile as sf


from transformers import SpeechT5Processor, SpeechT5ForTextToSpeech, SpeechT5HifiGan
from datasets import load_dataset
from transformers import Wav2Vec2ForCTC, Wav2Vec2Processor
from nltk.tokenize import sent_tokenize, word_tokenize
from transformers import pipeline
nltk.download('punkt')



current_dir = os.path.dirname(os.path.abspath(__file__))

""" # Construct the absolute path to the model and scalers
processor_path_stt= os.path.join(current_dir,"model/Wav2Vec/Wav2Vec2Processor")
model_path_stt= os.path.join(current_dir,"model/Wav2Vec/Wav2Vec2ForCTC")

# Load the saved tokenizer &model for speech to text
processor_stt = Wav2Vec2Processor.from_pretrained(processor_path_stt, local_files_only=True)
model_stt = Wav2Vec2ForCTC.from_pretrained(model_path_stt, local_files_only=True) """


# Construct the absolute path to the model and scalers
processor_path_tts= os.path.join(current_dir,"model/SpeechT5_TTS-model/SpeechT5Processor")
model_path_tts= os.path.join(current_dir,"model/SpeechT5_TTS-model/SpeechT5model")
vocoder_path_tts=os.path.join(current_dir,"model/SpeechT5_TTS-model/SpeechT5vocoder")

# Load the saved processor & model for text to speech model
processor_tts = SpeechT5Processor.from_pretrained(processor_path_tts, local_files_only=True)
model_tts = SpeechT5ForTextToSpeech.from_pretrained(model_path_tts, local_files_only=True)
vocoder_tts = SpeechT5HifiGan.from_pretrained(vocoder_path_tts, local_files_only=True)




""" def speech_to_text(audio_file):

    # Load pretrained model and processor
    #model = Wav2Vec2ForCTC.from_pretrained("facebook/wav2vec2-base-960h")
    ##processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-base-960h")


    #model.save_pretrained("Wav2Vec2ForCTC")
    #processor.save_pretrained("Wav2Vec2Processor")

    # Load pretrained model and processor
    #model_stt= Wav2Vec2ForCTC.from_pretrained("/content/drive/MyDrive/Work_space/Silverline_IT/Project/Learn_Joy/API/app/service03/fun03_model/Wav2Vec2ForCTC")
    #processor_stt = Wav2Vec2Processor.from_pretrained("/content/drive/MyDrive/Work_space/Silverline_IT/Project/Learn_Joy/API/app/service03/fun03_model/Wav2Vec2Processor")


    # Process audio input with specified sampling rate
    audio_input, _ = torchaudio.load(audio_file, normalize=True)
    sampling_rate = 16000  # Replace with the actual sampling rate of your audio file
    input_values = processor_stt(audio_input.squeeze().numpy(), return_tensors="pt", sampling_rate=sampling_rate).input_values

    # Perform inference
    with torch.no_grad():
      logits = model_stt(input_values).logits

    predicted_ids = torch.argmax(logits, dim=-1)
    transcription = processor_stt.batch_decode(predicted_ids)[0]

    return transcription
 """



async def text_to_speech(text,return_tensors="pt"):

  #load model in outside

  #processor = SpeechT5Processor.from_pretrained("microsoft/speecht5_tts")
  #model = SpeechT5ForTextToSpeech.from_pretrained("microsoft/speecht5_tts")
  #vocoder = SpeechT5HifiGan.from_pretrained("microsoft/speecht5_hifigan")


  # Save the models and their configurations to the specified directory

  #processor.save_pretrained("SpeechT5Processor")
  #model.save_pretrained("SpeechT5model")
  #vocoder.save_pretrained("SpeechT5vocoder")

  #processor = SpeechT5Processor.from_pretrained("SpeechT5Processor")
  #model = SpeechT5ForTextToSpeech.from_pretrained("SpeechT5model")
  #vocoder = SpeechT5HifiGan.from_pretrained("SpeechT5vocoder")


  #load model in local pc

  #processor_tts = SpeechT5Processor.from_pretrained(r"/content/drive/MyDrive/Work_space/Silverline_IT/Project/Learn_Joy/API/app/service03/fun03_model/SpeechT5_TTS-model/SpeechT5Processor", local_files_only=True)
  #model_tts = SpeechT5ForTextToSpeech.from_pretrained(r"/content/drive/MyDrive/Work_space/Silverline_IT/Project/Learn_Joy/API/app/service03/fun03_model/SpeechT5_TTS-model/SpeechT5model", local_files_only=True)
  #vocoder_tts = SpeechT5HifiGan.from_pretrained(r"/content/drive/MyDrive/Work_space/Silverline_IT/Project/Learn_Joy/API/app/service03/fun03_model/SpeechT5_TTS-model/SpeechT5vocoder", local_files_only=True)


  inputs = processor_tts (text=text, return_tensors=return_tensors)

  # load xvector containing speaker's voice characteristics from a dataset
  embeddings_dataset = load_dataset("Matthijs/cmu-arctic-xvectors", split="validation")
  speaker_embeddings = torch.tensor(embeddings_dataset[7306]["xvector"]).unsqueeze(0)

  speech = model_tts.generate_speech(inputs["input_ids"], speaker_embeddings, vocoder=vocoder_tts)

  # Ensure that speech is a 1D NumPy array
  speech_array = speech.numpy().flatten()

    
  

    # Return the audio file as a response & jasonrespons

  return speech_array 







