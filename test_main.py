import requests
import os
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("X_API_KEY")

def test_adpoint_customer():
    url = "http://localhost:8000/search_adpoint_customer"
    headers = {"X-API-Key": API_KEY}
    data = {"customerName": "1-800-Dentist"}
    
    response = requests.post(url, json=data, headers=headers)
    print(f"\nAdpoint Customer Status Code: {response.status_code}")
    print(f"Adpoint Customer Response: {response.json()}")

if __name__ == "__main__":
    test_adpoint_customer() 