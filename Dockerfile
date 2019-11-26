FROM rocker/tidyverse:3.6.1
COPY inst/extra/setup.R /
ADD  https://github.com/sk-sahu/sig-bio-shiny/archive/master.zip /app.tar.gz
COPY data /data
RUN Rscript setup.R \
	&& ls -la \
 	&& R -e 'remotes::install_local("/app.tar.gz")'
EXPOSE 80
CMD R -e "options('shiny.port'=80,shiny.host='0.0.0.0');SigBio::run_app()"
