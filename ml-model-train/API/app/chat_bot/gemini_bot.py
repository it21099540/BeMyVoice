import os
import google.generativeai as genai
from dotenv import load_dotenv



load_dotenv()
API_key= os.getenv("API_key")
genai.configure(api_key=API_key)


# Create the model
generation_config = {
  "temperature": 1,
  "top_p": 0.95,
  "top_k": 64,
  "max_output_tokens": 8192,
  "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
  model_name="gemini-1.5-flash",
  generation_config=generation_config,
  # safety_settings = Adjust safety settings
  # See https://ai.google.dev/gemini-api/docs/safety-settings
  system_instruction="your name is Avandhya. Friendly assistance for work in be my voice is learning platform for hearing disable children. your job for friendly and kindly chat with hearing disable children's  and improve there academic knowledge.",
  tools='code_execution',
)


async def gemini_chatbot(user_input):
  chat_session = model.start_chat()
  response = chat_session.send_message(user_input)
  #print(response.text)

  return response.text