# main.py — FastAPI middleware layer for Adpoint integration
import os
import requests
from fastapi import FastAPI, Header, HTTPException, Request, Depends
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from typing import Optional
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("X_API_KEY")
ADPOINT_AUTH_HEADER = os.getenv("ADPOINT_AUTH_HEADER")

app = FastAPI()

class Contact(BaseModel):
    ContactID: int
    CustomerID: int
    LastName: str
    FirstName: str
    MiddleName: str
    Position: str
    Phone: str
    Mobile: str
    Mail: str
    Active: bool
    ContactCategory: str

class AdpointCustomerResponse(BaseModel):
    CustomerID: int 
    CustomerName: str
    CustomerOwner: str
    Active: bool
    LocalSegment: str
    contacts: list[Contact]

class AdpointCustomerRequest(BaseModel):
    customerName: str

def verify_api_key(x_api_key: Optional[str] = Header(None)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API Key")

@app.post("/search_adpoint_customer", response_model=list[AdpointCustomerResponse])
async def search_adpoint_customer(request: AdpointCustomerRequest, _=Depends(verify_api_key)):
    if not ADPOINT_AUTH_HEADER:
        raise HTTPException(status_code=500, detail="Adpoint authorization header not configured")
        
    base_url = "https://your-adpoint-instance.com/agentaccess/webapi/v1"
    headers = {
        "Accept": "application/json",
        "Authorization": f"Basic {ADPOINT_AUTH_HEADER}"
    }

    try:
        # First, get customers
        customers_url = f"{base_url}/Customers"
        customers_params = {
            "query.customerName": request.customerName
        }
        
        customers_response = requests.get(customers_url, headers=headers, params=customers_params)
        customers_response.raise_for_status()
        customers = customers_response.json()

        # For each customer, get their contacts
        filtered_customers = []
        for customer in customers:
            # Get contacts for this customer
            contacts_url = f"{base_url}/Contacts"
            contacts_params = {
                "query.customerID": customer["CustomerID"]
            }
            
            contacts_response = requests.get(contacts_url, headers=headers, params=contacts_params)
            contacts_response.raise_for_status()
            contacts = contacts_response.json()

            # Filter and format contacts
            filtered_contacts = [
                {
                    "ContactID": c["ContactID"],
                    "CustomerID": c["CustomerID"],
                    "LastName": c["LastName"],
                    "FirstName": c["FirstName"],
                    "MiddleName": c["MiddleName"],
                    "Position": c["Position"],
                    "Phone": c["Phone"],
                    "Mobile": c["Mobile"],
                    "Mail": c["Mail"],
                    "Active": c["Active"],
                    "ContactCategory": c["ContactCategory"]
                }
                for c in contacts
            ]

            # Create customer response with contacts
            filtered_customers.append({
                "CustomerID": customer["CustomerID"],
                "CustomerName": customer["CustomerName"],
                "CustomerOwner": customer["CustomerOwner"],
                "Active": customer["Active"],
                "LocalSegment": customer["LocalSegment"],
                "contacts": filtered_contacts
            })

        return filtered_customers
    except requests.exceptions.RequestException as e:
        raise HTTPException(status_code=500, detail=f"Error calling Adpoint API: {str(e)}")

@app.exception_handler(Exception)
async def handle_all_exceptions(request: Request, exc):
    return JSONResponse(status_code=500, content={"message": "Internal error"})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

