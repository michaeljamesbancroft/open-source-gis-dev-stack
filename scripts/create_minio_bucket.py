import os
import boto3
from botocore.client import Config

endpoint = os.getenv(
    "S3_ENDPOINT_URL"
)

bucket = os.getenv(
    "S3_BUCKET"
)

client = boto3.client(
    "s3",

    endpoint_url=endpoint,

    aws_access_key_id=os.getenv(
        "MINIO_ROOT_USER"
    ),

    aws_secret_access_key=os.getenv(
        "MINIO_ROOT_PASSWORD"
    ),

    config=Config(
        signature_version="s3v4"
    ),
)

existing = [
    b["Name"]
    for b in client.list_buckets()["Buckets"]
]

if bucket not in existing:

    client.create_bucket(
        Bucket=bucket
    )

    print(
        f"Created bucket: {bucket}"
    )

else:

    print(
        f"Bucket already exists: {bucket}"
    )