FROM rocker/r-base

COPY api-controller.R /home/api-controller.R
COPY libraries.R /home/libraries.R
COPY serverStart.R /home/serverStart.R

WORKDIR /home

CMD ["Rscript", "serverStart.R"]

