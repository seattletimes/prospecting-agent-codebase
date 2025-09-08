# Prospecting Agent (Custom GPT) Setup Guide

This guide provides step-by-step instructions for creating a **News Times Lead Scoring & Business Research Copilot** as a custom GPT in ChatGPT Enterprise. This AI agent helps sales representatives identify, evaluate, and pursue high-potential advertising leads using data-backed analysis and strategic insights.

## Overview

The Prospecting Agent is a sophisticated AI assistant that:
- **Identifies** potential advertising leads by industry and location
- **Evaluates** leads using a comprehensive 10-category scoring system
- **Researches** businesses using live data and CRM integration
- **Provides** actionable recommendations for sales pursuit
- **Integrates** with Adpoint CRM for customer relationship data

## Prerequisites

### Required Access
- **ChatGPT Enterprise** account with MyGPT creation permissions
- **Admin access** to deploy the supporting API (see main project README)
- **Adpoint CRM** credentials for API integration

### Required Files
Ensure you have access to all files in the `Agent/` folder:
- `system_prompt.txt` - Core agent instructions and behavior
- `openAPI.json` - API specification for CRM integration
- `knowledge/Lead scoring Rulebook.pdf` - Scoring methodology
- `knowledge/Business Research Rulebook.pdf` - Research framework

## Step-by-Step Setup Instructions

### Step 1: Deploy the Supporting API

Before creating the custom GPT, you must deploy the API that powers the CRM integration:

1. **Navigate to the main project directory:**
   ```bash
   cd /path/to/prospecting-agent-codebase
   ```

2. **Follow the deployment instructions:**
   - See the main [README.md](../README.md) for local setup
   - See [deploy/DEPLOYMENT.md](../deploy/DEPLOYMENT.md) for Azure deployment

3. **Note the API endpoint URL** - you'll need this for the custom GPT configuration

### Step 2: Access ChatGPT Enterprise

1. **Log into ChatGPT Enterprise:**
   - Go to [chat.openai.com](https://chat.openai.com)
   - Ensure you're using an Enterprise account with MyGPT permissions

2. **Navigate to MyGPTs:**
   - Click on your profile icon (top right)
   - Select "MyGPTs" from the dropdown menu

### Step 3: Create a New Custom GPT

1. **Click "Create a GPT":**
   - This will open the GPT Builder interface

2. **Choose "Configure" tab:**
   - Switch from "Create" to "Configure" for manual setup

### Step 4: Configure Basic Information

#### Name and Description
- **Name:** `News Times Lead Scoring & Business Research Copilot`
- **Description:** `AI assistant for Seattle Times sales reps to identify, evaluate, and pursue high-potential advertising leads using data-backed analysis and CRM integration.`

#### Instructions
Copy and paste the entire content from `system_prompt.txt` into the Instructions field. This file contains:
- Role definition and mission statement
- Mandatory execution checklist
- Step-by-step process workflow
- Output format requirements
- Quality control measures

### Step 5: Configure Knowledge Base

1. **Upload Knowledge Files:**
   - Click "Add knowledge" or the paperclip icon
   - Upload `knowledge/Lead scoring Rulebook.pdf`
   - Upload `knowledge/Business Research Rulebook.pdf`

2. **Verify Upload:**
   - Ensure both PDFs appear in the knowledge section
   - These contain the scoring methodology and research framework

### Step 6: Configure Actions (API Integration)

1. **Click "Create new action":**
   - This opens the Actions configuration panel

2. **Import OpenAPI Schema:**
   - Click "Import from URL" or paste the schema directly
   - Copy the entire content from `openAPI.json`
   - Paste it into the schema field

3. **Configure Authentication:**
   - **Authentication Type:** API Key
   - **API Key:** Enter your API key (same as X_API_KEY from deployment)
   - **Auth Type:** Custom
   - **Custom Header Name:** `x-api-key`

4. **Update Server URL:**
   - In the schema, update the server URL to match your deployed API:
   ```json
   "servers": [
     {
       "url": "https://your-deployed-api.azurewebsites.net"
     }
   ]
   ```

### Step 7: Configure Conversation Starters

Add these conversation starters to help users get started:

1. **"Find 15 healthcare leads in Seattle"**
2. **"Evaluate this business: [Business Name]"**
3. **"Have we worked with [Company Name] before?"**
4. **"Generate leads for retail industry in Bellevue"**

### Step 8: Set Capabilities

Enable the following capabilities:
- ✅ **Web Browsing** - Required for live data research
- ✅ **Code Interpreter** - For data analysis and calculations
- ❌ **DALL-E Image Generation** - Not needed for this use case

### Step 9: Configure Privacy and Sharing

1. **Privacy Settings:**
   - Set to "Only me" for initial testing
   - Change to appropriate sharing level after validation

2. **Save Configuration:**
   - Click "Save" in the top right
   - Choose "Only me" for now
   - Name your GPT: `News Times Lead Scoring & Business Research Copilot`

### Step 10: Test the Custom GPT

#### Test Scenarios

1. **Lead Generation Test:**
   ```
   Find 10 technology companies in Seattle
   ```

2. **Lead Evaluation Test:**
   ```
   Evaluate this business: Microsoft Corporation
   ```

3. **CRM Integration Test:**
   ```
   Have we worked with Starbucks before?
   ```

#### Expected Behaviors

The agent should:
- ✅ Follow the 8-step process outlined in the system prompt
- ✅ Use the browser for live data research
- ✅ Query the API for CRM data using all 5 variant searches
- ✅ Apply the 10-category scoring system
- ✅ Generate properly formatted reports
- ✅ Provide actionable recommendations

### Step 11: Fine-tuning and Optimization

#### Common Issues and Solutions

1. **API Connection Errors:**
   - Verify the API endpoint URL is correct
   - Check that the API key is properly configured
   - Ensure the API is deployed and accessible

2. **Knowledge Base Issues:**
   - Re-upload PDF files if content isn't being referenced
   - Check that file names match exactly

3. **Formatting Problems:**
   - Review the system prompt for exact format requirements
   - Test with simple queries first

#### Performance Optimization

1. **Monitor API Usage:**
   - Track API calls to ensure efficient usage
   - Monitor response times and error rates

2. **Update Knowledge Base:**
   - Refresh PDF files when scoring criteria change
   - Add new industry-specific knowledge as needed

### Step 12: Deployment and Sharing

1. **Final Testing:**
   - Run comprehensive tests with real business scenarios
   - Verify all scoring categories work correctly
   - Test edge cases and error handling

2. **Share with Team:**
   - Change privacy settings to appropriate level
   - Share with sales team members
   - Provide training on usage and best practices

## File Reference Guide

### Core Configuration Files

| File | Location | Purpose |
|------|----------|---------|
| `system_prompt.txt` | `Agent/system_prompt.txt` | Core agent instructions and behavior |
| `openAPI.json` | `Agent/openAPI.json` | API specification for CRM integration |
| `Lead scoring Rulebook.pdf` | `Agent/knowledge/Lead scoring Rulebook.pdf` | 10-category scoring methodology |
| `Business Research Rulebook.pdf` | `Agent/knowledge/Business Research Rulebook.pdf` | Research framework and structure |

### Supporting Infrastructure

| Component | Location | Purpose |
|-----------|----------|---------|
| API Code | `main.py` | FastAPI application for CRM integration |
| Deployment Scripts | `deploy/` | Azure deployment automation |
| Documentation | `README.md` | Main project documentation |

## Troubleshooting

### Common Issues

1. **"API not responding"**
   - Check API deployment status
   - Verify endpoint URL in OpenAPI schema
   - Test API directly using curl or Postman

2. **"Knowledge base not found"**
   - Re-upload PDF files
   - Check file names match exactly
   - Ensure files are properly formatted

3. **"Scoring format incorrect"**
   - Review system prompt formatting requirements
   - Check that knowledge base PDFs are accessible
   - Verify all 10 categories are being scored

### Support Resources

- **API Documentation:** Available at `https://your-api-url/docs`
- **Deployment Issues:** See `deploy/DEPLOYMENT.md`
- **System Prompt Issues:** Review `Agent/system_prompt.txt`
- **Scoring Questions:** Reference `Agent/knowledge/Lead scoring Rulebook.pdf`

## Best Practices

### For Sales Representatives

1. **Be Specific:** Provide clear industry and location criteria
2. **Use Full Names:** Include complete business names for evaluation
3. **Follow Up:** Use the research reports for targeted outreach
4. **Verify Data:** Cross-check critical information before outreach

### For Administrators

1. **Monitor Usage:** Track API calls and performance metrics
2. **Update Knowledge:** Keep scoring criteria and research frameworks current
3. **Test Regularly:** Validate agent performance with new scenarios
4. **Backup Configuration:** Save GPT configuration for disaster recovery

## Maintenance and Updates

### Regular Maintenance Tasks

1. **Monthly:**
   - Review API performance and error rates
   - Update knowledge base with new industry insights
   - Test agent with new business scenarios

2. **Quarterly:**
   - Review and update scoring criteria
   - Analyze usage patterns and optimize performance
   - Update system prompt based on user feedback

3. **As Needed:**
   - Update API endpoint URLs if infrastructure changes
   - Refresh knowledge base when business rules change
   - Retrain team on new features or capabilities

## Success Metrics

Track these metrics to measure agent effectiveness:

- **Lead Generation Accuracy:** Percentage of leads that convert to opportunities
- **Research Quality:** Completeness and accuracy of business research
- **Time Savings:** Reduction in manual research time
- **User Adoption:** Number of active users and queries per day
- **API Performance:** Response times and error rates

---

## Quick Reference

### Essential Files
- **System Prompt:** `Agent/system_prompt.txt`
- **API Schema:** `Agent/openAPI.json`
- **Scoring Guide:** `Agent/knowledge/Lead scoring Rulebook.pdf`
- **Research Guide:** `Agent/knowledge/Business Research Rulebook.pdf`

### Key URLs
- **ChatGPT Enterprise:** https://chat.openai.com
- **API Documentation:** `https://your-deployed-api.azurewebsites.net/docs`
- **Deployment Guide:** `../deploy/DEPLOYMENT.md`

### Support
For technical issues, refer to the main project documentation or contact the development team.