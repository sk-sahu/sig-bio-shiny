FROM codingene/bioshiner:3.10
LABEL maintainer="Sangram Keshari Sahu <sangramsahu15@gmail.com>"
RUN	R -e 'remotes::install_github("sk-sahu/sig-bio-shiny", ref = "dev")'
COPY app.R /srv/shiny-server/
EXPOSE 3838

#CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');SigBio::run_app()"
