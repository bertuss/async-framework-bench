FROM python:3.7.1-slim

WORKDIR /usr/src/app

COPY . .

RUN pip install -r requirements.txt

CMD gunicorn app:app -c server_config.py