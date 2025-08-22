import os
from flask import Flask, jsonify, request
import pyodbc
from pprint import pprint
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential
import uuid
from datetime import datetime
import json

app = Flask(__name__)

credential = DefaultAzureCredential()
blob_service_client = BlobServiceClient(os.environ['STORAGE_ACCOUNT_URL'], credential)
container_client = blob_service_client.get_container_client("api-logs")



@app.route('/restaurants', methods=['GET'])
def handle():
    print('Request received')
    print(request.args)

    name = request.args.get('name')
    style = request.args.get('style')
    vegetarian = request.args.get('vegetarian')
    doesDeliveries = request.args.get('doesDeliveries')
    openAt = request.args.get('openAt')

    subqueries = []

    if name:
        subqueries.append(f"Name = \'{name}\'")
    if style:
        subqueries.append(f"Style = \'{style}\'")
    if vegetarian:
        subqueries.append(f"Vegetarian = {int(vegetarian.lower() == 'yes')}")
    if doesDeliveries:
        subqueries.append(f"DoesDeliveries = {int(doesDeliveries.lower() == 'yes')}")
    if openAt:
        subqueries.append(f"OpeningHour <= \'{openAt}\' AND ClosingHour >= \'{openAt}\'")

    if subqueries:
        query = f"SELECT * FROM Restaurant WHERE {subqueries[0]}"

        if len(subqueries) >= 2:
            for q in subqueries[1:]:
                query += f" AND {q}"

        query += ";"

        print("Query: ", query)

        conn_str = os.environ["SQLCONNSTR_connectionString1"]
        conn = pyodbc.connect(conn_str)
        cursor = conn.cursor()
        cursor.execute(query)
        rows = cursor.fetchall()
        cursor.close()
        conn.close()

        response = {"restaurantRecommendation": []}

        for row in rows:
            response["restaurantRecommendation"].append({
                "name": row[0],
                "address": row[1],
                "style": row[2],
                "vegetarian": row[3],
                "doesDeliveries": row[4],
                "openingHour": row[5].strftime('%H:%M'),
                "closingHour": row[6].strftime('%H:%M')
            })

        pprint(response)

        return jsonify(response)

    else:
        return jsonify({"error": "no query provided"}), 400



@app.after_request
def log_request_response(response):
    if request.path == "/restaurants":
        timenow = datetime.utcnow()

        log_data = {
            "timestamp": timenow.isoformat(),
            "endpoint": request.path,
            "request_params": request.args.to_dict(),
            "response_data": response.get_data(as_text=True),
            "status_code": response.status_code
        }

        log_json = json.dumps(log_data)
        
        blob_name = f"{timenow.strftime('%Y-%m-%d')}/{uuid.uuid4()}.json"

        try:
            blob_client = container_client.get_blob_client(blob_name)
            blob_client.upload_blob(log_json, overwrite=True)
            print(f"Log saved to Azure Blob Storage with blob name: {blob_name}")
            
        except Exception as e:
            print(f"Failed to save log to Azure Blob Storage: {str(e)}")

    return response



if __name__ == '__main__':
    app.run()
