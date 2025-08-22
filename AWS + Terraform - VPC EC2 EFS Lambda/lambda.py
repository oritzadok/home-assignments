from urllib.request import urlretrieve

def lambda_handler(event, context):
	path, headers = urlretrieve("https://api.apis.guru/v2/providers.json", "/mnt/efs/providers.json")
	for name, value in headers.items():
		print(name, value)