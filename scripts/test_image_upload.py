import boto3
from botocore.exceptions import NoCredentialsError

BUCKET_NAME = 'nolanmiller-image-hosting'
IMAGE_PATH = '/Users/nolanmiller/Library/CloudStorage/GoogleDrive-nolan.miller77@gmail.com/My Drive/Vault/3 - Resources/pictures/headshot.jpg'
IMAGE_KEY = 'headshot.jpg'

s3 = boto3.client('s3')

def upload_image_to_s3(image_path, bucket_name, image_key):
    try:
        s3.upload_file(image_path, bucket_name, image_key)
        print(f"Image uploaded to S3: {image_key}")

        image_uri = f"https://{bucket_name}.s3.amazonaws.com/{image_key}"
        print("Image uploaded successfully.")
        print("Image URI:", image_uri)
        return image_uri

    except FileNotFoundError:
        print("The file was not found")
    except NoCredentialsError:
        print("Credentials not available")

upload_image_to_s3(IMAGE_PATH, BUCKET_NAME, IMAGE_KEY)