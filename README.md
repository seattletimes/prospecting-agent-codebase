# Prospecting Agent API

A FastAPI-based middleware service that provides integration with Adpoint customer management system for AI agents in the advertising team.

## Overview

This service acts as a secure API layer between AI agents and the Adpoint customer database, enabling automated customer and contact information retrieval for prospecting activities.

🤖 **AI Agent Integration**: This API is designed to work with a custom ChatGPT Enterprise agent called the "Seattle Times Lead Scoring & Business Research Copilot" that helps sales representatives identify, evaluate, and pursue high-potential advertising leads.

📋 **[Agent Setup Guide](Agent/Agent-README.md)** - Complete instructions for creating the custom GPT agent

## Features

- **Adpoint Customer Search**: Search for customers by name and retrieve detailed contact information
- **API Key Authentication**: Secure endpoint access with configurable API keys
- **Contact Management**: Retrieve comprehensive contact details including phone, email, and position information
- **Error Handling**: Robust error handling with appropriate HTTP status codes
- **AI Agent Integration**: Powers a custom ChatGPT Enterprise agent for automated lead scoring and business research

## API Endpoints

### POST `/search_adpoint_customer`

Search for customers in the Adpoint system and retrieve their contact information.

**Request Body:**
```json
{
  "customerName": "string"
}
```

**Response:**
```json
[
  {
    "CustomerID": 123,
    "CustomerName": "Example Company",
    "CustomerOwner": "John Doe",
    "Active": true,
    "LocalSegment": "Enterprise",
    "contacts": [
      {
        "ContactID": 456,
        "CustomerID": 123,
        "LastName": "Smith",
        "FirstName": "Jane",
        "MiddleName": "A",
        "Position": "Marketing Director",
        "Phone": "+1-555-0123",
        "Mobile": "+1-555-0124",
        "Mail": "jane.smith@example.com",
        "Active": true,
        "ContactCategory": "Primary"
      }
    ]
  }
]
```

**Headers Required:**
- `X-API-Key`: Your API key for authentication

## Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd prospecting-agent-codebase
   ```

2. **Create and activate a virtual environment:**
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

## Configuration

Create a `.env` file in the project root with the following environment variables:

```env
# API Authentication
X_API_KEY=your_secure_api_key_here

# Adpoint Integration
ADPOINT_AUTH_HEADER=your_base64_encoded_adpoint_credentials
```

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `X_API_KEY` | API key for endpoint authentication | Yes |
| `ADPOINT_AUTH_HEADER` | Base64 encoded credentials for Adpoint API access | Yes |

## Running the Application

### Development Mode

```bash
python main.py
```

The server will start on `http://localhost:8000`

### Production Mode

```bash
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Using the Startup Script

```bash
chmod +x startup.sh
./startup.sh
```

## Testing

Run the test script to verify the API functionality:

```bash
python test_main.py
```

Make sure to set your environment variables before running tests.

## API Documentation

Once the server is running, you can access:

- **Interactive API Documentation**: `http://localhost:8000/docs`
- **ReDoc Documentation**: `http://localhost:8000/redoc`
- **OpenAPI Schema**: `http://localhost:8000/openapi.json`

## Azure Deployment

This project includes automated deployment scripts for Azure App Service. For detailed deployment instructions, see:

📋 **[Deployment Documentation](deploy/DEPLOYMENT.md)**

### Quick Deployment Commands

**First-time deployment:**
```bash
cd deploy
./initial-deploy.sh
```

**Update existing deployment:**
```bash
cd deploy
./redeploy.sh
```

The deployment scripts will:
- Create Azure App Service with Python 3.11 runtime
- Set up Application Insights for monitoring
- Configure environment variables securely
- Deploy the application as a zip package

## Project Structure

```
prospecting-agent-codebase/
├── main.py              # FastAPI application and endpoints
├── test_main.py         # Test script for API endpoints
├── requirements.txt     # Python dependencies
├── startup.sh          # Production startup script
├── .env                # Environment variables (create this)
├── .gitignore          # Git ignore rules
├── deploy/             # Azure deployment scripts
│   ├── initial-deploy.sh    # First-time deployment
│   ├── redeploy.sh         # Update deployment
│   └── DEPLOYMENT.md       # Deployment documentation
├── Agent/              # Custom GPT agent configuration
│   ├── Agent-README.md     # Agent setup instructions
│   ├── system_prompt.txt   # Agent behavior and instructions
│   ├── openAPI.json        # API schema for agent integration
│   └── knowledge/          # Agent knowledge base
│       ├── Lead scoring Rulebook.pdf
│       └── Business Research Rulebook.pdf
└── README.md           # This documentation
```

## Dependencies

- **FastAPI**: Modern, fast web framework for building APIs
- **Uvicorn**: ASGI server for running FastAPI applications
- **Pydantic**: Data validation using Python type annotations
- **Requests**: HTTP library for making API calls to Adpoint
- **Python-dotenv**: Load environment variables from .env files

## Security

- All endpoints require API key authentication via the `X-API-Key` header
- Environment variables are used for sensitive configuration
- No default API keys are provided (must be explicitly configured)

## Error Handling

The API returns appropriate HTTP status codes:

- `200`: Success
- `401`: Invalid or missing API key
- `500`: Internal server error or Adpoint API errors

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Submit a pull request

## License

This project is for internal use by the advertising team.

## Complete Solution Architecture

This project provides a complete AI-powered prospecting solution consisting of:

### 1. **API Backend** (This Repository)
- FastAPI service for Adpoint CRM integration
- Secure customer data retrieval
- RESTful API with authentication

### 2. **AI Agent** (Custom GPT)
- ChatGPT Enterprise custom agent
- Automated lead scoring and research
- Natural language interaction
- Integration with the API backend

### 3. **Knowledge Base**
- Lead scoring methodology (10-category system)
- Business research framework
- Industry-specific guidelines

### 4. **Deployment Infrastructure**
- Azure App Service hosting
- Application Insights monitoring
- Automated deployment scripts

## Getting Started - Complete Setup

1. **Deploy the API**: Follow the [deployment guide](deploy/DEPLOYMENT.md)
2. **Create the Agent**: Follow the [agent setup guide](Agent/Agent-README.md)
3. **Test the Integration**: Use the provided test scenarios
4. **Train Your Team**: Share best practices and usage guidelines

## Support

For issues or questions, please contact the development team or create an issue in the repository.