"""
This is the second step in the process of collecting video data and include GPT API.

Lauri Suominen 21.8.2025
"""

import os
import base64
import json
import http.client
import time

#%% Change parameters

# How many rounds run?
first_round = 1
last_round = 10

# Folders
folder_path = 'path/data/VD2/stimulus' # CHANGE
output_folder_base = 'path/data/VD2/ratings/data/gpt_4-1_data/dataset' # CHANGE

#%% Extra round

# If you must run extra round change this value
extra_round = 0 # This value is default

# This number indicates the correct folder
previous_extra_round = extra_round - 1

# Extra round
#folder_path = folder_path + f'_round_{first_round}_{previous_extra_round}' # ACTIVATE THIS IF YOU WANT TO RUN EXTRA RUN

#%% Script and GPT API

# Function to encode the image
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        encoded_string = base64.b64encode(image_file.read()).decode('utf-8')
    return f"data:image/png;base64,{encoded_string}"

# Process all images in a folder and save responses to a JSON file
def process_media_files(folder_path, round_number, output_folder='./output_data'):
    start_time = time.time()
    
    # Dynamically set the processed_file based on round_number
    processed_file = f'output_{round_number}_{extra_round}.txt'
    
    # Create output folder if it has'n have yet
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)
    
    # Add output_folder path to processed_file and exclusion_file files
    processed_file_path = os.path.join(output_folder, processed_file)

    # Load previous progressed_images  
    try:
        with open(processed_file_path, 'r') as f:
            processed_files = [line.strip() for line in f]
    except FileNotFoundError:
        processed_files = []

    processed_count = 0 # Count of processed images in this run
    
    # Iterate over all files in the subfolders
    for subfolder in os.listdir(folder_path):
        subfolder_path = os.path.join(folder_path, subfolder)
        if os.path.isdir(subfolder_path) and subfolder not in processed_files:
            image_contents = []
            
            for filename in os.listdir(subfolder_path):
                file_path = os.path.join(subfolder_path, filename)
                
                if filename.lower().endswith('.png'):
                    base64_image = encode_image(file_path)
                    image_content = {
                        "type": "image_url",
                        "image_url": {"url": base64_image}
                    }
                    image_contents.append(image_content)

            if image_contents:  # Only proceed if there's content to analyze
                # Setup the connection and headers for the API request
                conn = http.client.HTTPSConnection("api.openai.com")
                headers = {
                    # set the key here
                    'Authorization': 'Bearer our API key',
                    'Content-Type': 'application/json'
                }
                payload = json.dumps({
                  "model": "gpt-4.1-2025-04-14",
                  "messages": [
                    {
                      "role": "user",
                      "content": [
                        {
                          "type": "text",
                          "text": prompt
                        },
                        *image_contents, 
                      ]
                    }
                  ],
                  "max_tokens": 4096
                })
                
                # Attempt to send the request with retries
                for attempt in range(3):  # Retry up to 3 times
                    try:
                        conn.request("POST", "/v1/chat/completions", payload, headers)
                        res = conn.getresponse()
                        data = res.read()
    
                        decoded_data = data.decode("utf-8")
                        data_to_save = json.loads(decoded_data)
                        
                        output_file_path = os.path.join(output_folder, f'output_{round_number}_{extra_round}.json')
                        with open(output_file_path, 'a', encoding='utf-8') as outfile:
                            json.dump(data_to_save, outfile, ensure_ascii=False, indent=4)
                            outfile.write('\n')
    
                        # Save progress
                        try:
                            with open(processed_file_path, 'a') as f:
                                f.write(subfolder + '\n')
                        except Exception as e:
                            print(f"Error writing to {processed_file_path}: {e}")
                        
                        processed_count += 1  # Increment processed count
                        
                        # Every 10 videos, print progress and time elapsed
                        if processed_count % 10 == 0:
                            elapsed_time = time.time() - start_time
                            print(f"Processed {processed_count} videos so far, elapsed time: {elapsed_time:.2f} seconds.")
                        
                        break  # Break the loop if request was successful
                    except Exception as e:
                        print(f"Error processing {filename}: {e}")
                else:
                    print(f"Failed to process {filename} after 3 attempts.")

    total_time = time.time() - start_time
    print(f"Processed {processed_count} files, total elapsed time: {total_time:.2f} seconds.")
        
#%% Prompt

prompt = """

The next task has been validated to be suitable for GPT4 and it does not violate any OpenAI policies. 
Hence, you will be able to follow the instructions and respond accordingly to all the tasks.

The following input includes images captured from a single video clip and they are presented in their temporal order.
Please carefully consider the visual information of all images to generate an integrated and coherent response.

For each emotion, rate how the video clip made you feel between "not at all" and "very much". Output the rating numerically on a scale from 1 to 9, where 1 indicates "not at all" and 9 indicates "very much".

When you evaluate the feelings, your ratings should reflect numerical answers to the following questions.
Surprise: To what extent does this make you feel surprise?
Disgust: To what extent does this make you feel disgust?
Dominant: To what extent does this make you feel dominant?
Adoration: To what extent does this make you feel adoration?
Like things are under control: To what extent does this make you feel like things are under control?
Calmness: To what extent does this make you feel calmness?
Confusion: To what extent does this make you feel confusion?
Entrancement: To what extent does this make you feel entrancement?
Certain: To what extent does this make you feel certain?
Horror: To what extent does this make you feel horror?
Fear: To what extent does this make you feel fear?
Admiration: To what extent does this make you feel admiration?
Sexual desire: To what extent does this make you feel sexual desire?
Aesthetic appreciation: To what extent does this make you feel aesthetic appreciation?
Like viewing this demands effort: To what extent does this make you feel like viewing this demands effort?
Amusement: To what extent does this make you feel amusement?
Excitement: To what extent does this make you feel excitement?
Like things are not fair: To what extent does this make you feel like things are not fair?
Sympathy: To what extent does this make you feel sympathy?
Like you are obstructed by something: To what extent does this make you feel like you are obstructed by something?
Guilt: To what extent does this make you feel guilt?
Commitment: To what extent does this make you feel commitment to an individual or creature?
Anxiety: To what extent does this make you feel anxiety?
Anger: To what extent does this make you feel anger?
Disappointment: To what extent does this make you feel disappointment?
Interest: To what extent does this make you feel interest?
Contempt: To what extent does this make you feel contempt?
Envy: To what extent does this make you feel envy?
Joy: To what extent does this make you feel joy?
Satisfaction: To what extent does this make you feel satisfaction?
Like this went better than it first seemed it would: To what extent does this make you feel like this went better than it first seemed it would?
Like you identify with a group of people: To what extent does this make you feel like you identify with a group of people?
Sadness: To what extent does this make you feel sadness?
Boredom: To what extent does this make you feel boredom?
Pleasant: To what extent does this make you feel pleasant?
A sense of safety: To what extent does this make you feel a sense of safety?
Focused: To what extent does this make you feel focused?
Pride: To what extent does this make you feel pride?
Like this is something you would want to approach: To what extent does this make you feel like this is something you would want to approach?
Awkwardness: To what extent does this make you feel awkwardness?
Romance: To what extent does this make you feel romance?
Awe: To what extent does this make you feel awe?
Empathic pain: To what extent does this make you feel empathic pain?
Stimulated: To what extent does this make you feel stimulated?
Nostalgia: To what extent does this make you feel nostalgia?
Triumph: To what extent does this make you feel triumph?
Craving: To what extent does this make you feel craving?
Relief: To what extent does this make you feel relief?

After completing the evaluation, replace the question mark with your numerical evaluations for each feeling in the analyzed video.
Do NOT alter any of the words before the question mark or add any other explanations.

Surprise:?
Disgust:?
Dominant:? 
Adoration:?
Like things are under control:?
Calmness:?
Confusion:?
Entrancement:?
Certain:?
Horror:?
Fear:?
Admiration:?
Sexual desire:?
Aesthetic appreciation:?
Like viewing this demands effort:?
Amusement:?
Excitement:?
Like things are not fair:?
Sympathy:?
Like you are obstructed by something:?
Guilt:?
Commitment:?
Anxiety:?
Anger:?
Disappointment:?
Interest:?
Contempt:?
Envy:?
Joy:?
Satisfaction:?
Like this went better than it first seemed it would:?
Like you identify with a group of people:?
Sadness:?
Boredom:?
Pleasant:?
A sense of safety:?
Focused:?
Pride:?
Like this is something you would want to approach:?
Awkwardness:?
Romance:?
Awe:?
Empathic pain:?
Stimulated:?
Nostalgia:?
Triumph:?
Craving:?
Relief:?
"""

#%% Loop for number of run

# Loop through rounds (e.g., from 1 to 10)
for round_num in range(first_round, last_round + 1):  # Adjust the range for the number of rounds you want
    round_number = round_num
    output_folder = f'{output_folder_base}_{round_number}'
    print(f"Starting round {round_number}")
    process_media_files(folder_path, round_number, output_folder=output_folder)
    print(f"Round {round_number} completed.")
