FROM python:3.7.1-slim

WORKDIR /usr/src/app

COPY . .

RUN pip install -r requirements.txt

CMD python app.py --host=0.0.0.0 --port=8000 --uvloop