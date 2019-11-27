FROM rocker/shiny:3.6.1
LABEL maintainer="Sangram Keshari Sahu <sangramsahu15@gmail.com>"
RUN apt-get update &&\
  apt-get install libxml2-dev libssl-dev -y 
RUN R -e 'install.packages("remotes")'
RUN	R -e 'remotes::install_github("sk-sahu/sig-bio-shiny", ref = "dev")'
COPY app.R /srv/shiny-server/
EXPOSE 3838

#CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');SigBio::run_app()"
