import os
import json
import re
import yaml
import requests

def load_api_key():
        """Reads the API key from the .json file the directory."""
        script_dir = os.path.dirname(os.path.abspath(__file__))
        config_path = os.path.join(script_dir, "keys.json")

        try: 
            with open(config_path, 'r', encoding='utf-8') as config_file:
                config = json.load(config_file)
                return config.get("devto_key")
        except Exception as e:
                print(f"Error loading API key: {e}")
                return None

# Define constants
FOLDER_PATH = "C:\\Users\\NMiller\\OneDrive - CAB\\Documents\\Vault\\blog-posts"
DEV_API_URL = "https://dev.to/api/articles"
API_KEY = load_api_key()
if not API_KEY:
    raise ValueError("API key is missing or could not be loaded. Check keys.json for a devto_key.")



def read_front_matter(file_path):
    """Reads the front matter from a file."""
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
            if content.startswith('---'):
                parts = content.split('---', 2)
                front_matter = yaml.safe_load(parts[1])
                body = parts[2].strip()
                return front_matter, body
        return None, None
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None, None

def post_to_dev(article_data):
    """Posts an article to DEV."""
    headers = {
        "api-key": API_KEY,
        "Content-Type": "application/json"
    }
    try:
        response = requests.post(DEV_API_URL, json={"article": article_data}, headers=headers)
        if response.status_code == 201:
            print(f"Article '{article_data['title']}' posted successfully.")
        else:
            print(f"Failed to post article '{article_data['title']}': {response.status_code} {response.text}")
    except Exception as e:
        print(f"Error posting article: {e}")

def generate_canonical_url(title):
    slug = title.lower()
    slug = slug.replace(" ", "-")
    slug = re.sub(r"[^a-z0-9-]", "", slug)
    canonical_url = f"https://nolanmiller.me/posts/{slug}"
    return canonical_url

def process_folder(folder_path):
    """Processes all files in the folder and updates the 'dev' field in the front matter."""
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            try:
                # Read the file content
                with open(file_path, 'r', encoding='utf-8') as file:
                    content = file.read()

                # Extract the front matter between '---'
                front_matter_match = re.match(r"---\s*(.*?)\s*---", content, re.DOTALL)
                if front_matter_match:
                    front_matter_str = front_matter_match.group(1)

                    # Check if 'dev' field exists and is False
                    if "dev: false" in front_matter_str:
                        # Replace the 'dev' field value to 'true'
                        updated_front_matter_str = front_matter_str.replace("dev: false", "dev: true")

                        # Replace the old front matter with the updated one
                        updated_content = content.replace(front_matter_str, updated_front_matter_str)

                        # Write the updated content back to the file
                        with open(file_path, 'w', encoding='utf-8') as file:
                            file.write(updated_content)

                        print(f"Updated 'dev' field to True for {file_name}.")

            except Exception as e:
                print(f"Error processing {file_path}: {e}")

process_folder(FOLDER_PATH)
print("Pushes to DEV.to finished successfully.")
