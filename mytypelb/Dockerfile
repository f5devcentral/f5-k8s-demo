From python:3.8
WORKDIR /code
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY crdtypelb.py .
CMD [ "python", "./crdtypelb.py", "--incluster"]

