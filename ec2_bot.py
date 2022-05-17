import boto3
import time
import os
# import ast

os.environ['TZ'] = "Asia/Seoul"
time.tzset()
    
region = "ap-northeast-2"

ids = os.environ['id']
ids = ids.split(',')
ids = [n.strip() for n in ids]


ec2 = boto3.client('ec2', region_name=region)

def lambda_handler(event, context):
    # print(ids)
    
    curH = time.localtime().tm_hour 
    
    if curH < 12:
        ec2.start_instances(InstanceIds=ids)
    else:
        ec2.stop_instances(InstanceIds=ids)
    
