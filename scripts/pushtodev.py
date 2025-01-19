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
    """Processes all files in the folder."""
    for file_name in os.listdir(folder_path):
        file_path = os.path.join(folder_path, file_name)
        if os.path.isfile(file_path):
            front_matter, body = read_front_matter(file_path)
            if front_matter and front_matter.get('dev') == False and front_matter.get('draft') == False:
                article_data = {
                    "title": front_matter.get("title", "Untitled"),
                    "body_markdown": body,
                    "published": True,
                    "series": front_matter.get("series", None),
                    "canonical_url": generate_canonical_url(front_matter.get('title', 'Untitled')),
                    "description": front_matter.get("description"),
                    "tags": front_matter.get("tags", [])
                }
                print("articleData")
                post_to_dev(article_data)

                front_matter['dev'] = True

                new_front_matter = yaml.dump(front_matter, default_flow_style=False)
                new_content = f"---\n{new_front_matter}---\n{body}"

                try:
                    with open(file_path, 'w', encoding='utf-8') as file:
                        file.write(new_content)
                    print(f"Updated 'dev' field to True for {file_name}.")
                except Exception as e:
                    print(f"Error writing updated front matter to {file_path}: {e}")

process_folder(FOLDER_PATH)
print("Pushes to DEV.to finished successfully.")
