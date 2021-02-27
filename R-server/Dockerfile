FROM rocker/r-base:latest

COPY . /app/r-server
COPY /data/ /app/r-server/data
COPY /rscript/ /app/r-server/rscript 

WORKDIR /app/r-server

CMD ["Rscript", "serverStart.R"]

