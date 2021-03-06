FROM python:3.7.4-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD gunicorn app:app -c server_config.py