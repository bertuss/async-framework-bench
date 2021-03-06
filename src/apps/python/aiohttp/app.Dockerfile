FROM python:3.7.4-slim

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt

CMD python app.py --host=0.0.0.0 --port=8000 --uvloop