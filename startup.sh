#!/bin/bash
#pip install -r /home/site/wwwroot/requirements.txt
exec uvicorn main:app --host 0.0.0.0 --port 8000
