from transformers import AutoModelForCausalLM, AutoModelForSpeechSeq2Seq, AutoProcessor, pipeline
import os
import torch
import librosa
import numpy as np
import warnings

warnings.filterwarnings("ignore")

current_direction=current_dir = os.path.dirname(os.path.abspath(__file__))
# Load assistant model
assistant_model = AutoModelForCausalLM.from_pretrained(os.path.join(current_direction,"model/whisper-medium/assistant_model"))
# Load speech model
model = AutoModelForSpeechSeq2Seq.from_pretrained(os.path.join(current_direction,"model/whisper-medium/speech_model"))
# Load processor
processor = AutoProcessor.from_pretrained(os.path.join(current_direction,"model/whisper-medium/processor"))


# Device and Model Setup
device = "cuda:0" if torch.cuda.is_available() else "cpu"
torch_dtype = torch.float16 if torch.cuda.is_available() else torch.float32


model.to(device)

# Set up pipeline (without using ffmpeg)
pipe = pipeline(
    "automatic-speech-recognition",
    model=model,
    tokenizer=processor.tokenizer,
    feature_extractor=processor.feature_extractor,
    generate_kwargs={"assistant_model": assistant_model},
    torch_dtype=torch_dtype,
    device=device,
)

def whisper_ASR(audio_path):
    # Load audio using librosa
    audio_input, sample_rate = librosa.load(audio_path, sr=16000)  # Load and resample to 16kHz
    
    # Convert audio to a batch format expected by the pipeline
    input_features = processor.feature_extractor(audio_input, return_tensors="pt", sampling_rate=16000).input_features

    with torch.no_grad():
        input_features = input_features.to(device)
        # Generate the prediction
        predicted_ids = model.generate(input_features)
    
    # Decode the prediction into text
    transcription = processor.tokenizer.batch_decode(predicted_ids, skip_special_tokens=True)[0]
    
    #print(f"Transcription: {transcription}")
    return transcription


