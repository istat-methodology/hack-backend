FROM continuumio/anaconda3
COPY . /app
COPY /data/ /app
WORKDIR /app
RUN conda install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]