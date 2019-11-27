# sig-bio-shiny

<!-- badges: start -->
  [![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
  [![Build Status](https://travis-ci.org/sk-sahu/sig-bio-shiny.svg?branch=master)](https://travis-ci.org/sk-sahu/sig-bio-shiny)
  [![CircleCI](https://circleci.com/gh/sk-sahu/sig-bio-shiny.svg?style=svg)](https://circleci.com/gh/sk-sahu/sig-bio-shiny)
  [![GitHub release (latest by date)](https://img.shields.io/github/v/release/sk-sahu/sig-bio-shiny)](https://github.com/sk-sahu/sig-bio-shiny/releases)
  [![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/sudosk/sig-bio-shiny)](https://hub.docker.com/repository/docker/sudosk/sig-bio-shiny/builds)
<!-- badges: end -->

R shiny application for doing significant biology on a set of genes. 

**Significant Biology** is an important step of any high-throughput sequence analysis. Once you maped and/or assembled sequenced reads followed by feature(gene/isoform) quantification and/or diffrential analysis you will end up with set of genes. Quickly explore those genes from diffrent aspect what gives an idea about the Biology they involved in. Here comes this **SigBio** Shiny application. This is platform where with a set of genes you can do **Gene Ontology (GO), KEGG Pathway, Enrichment, Annotation and many things (will be discussed soon).**

## Advantage
Will be added


1. [Requirement](#requirement)
2. [Download](#download)
3. [Set Up](#set-up)
4. [Run the shiny app](#run-the-shiny-app)

## Requirement
Need atleast 8GB of RAM in the system

## Download
Install as a R package
```r
if (!requireNamespace("remotes", quietly = TRUE))
    install.packages("remotes")

remotes::install_github("sk-sahu/sig-bio-shiny")
```
OR

Clone using git
```bash
git clone https://github.com/sk-sahu/sig-bio-shiny.git
```

Download a specific version using wget
```bash
wget https://github.com/sk-sahu/sig-bio-shiny/archive/v0.1.zip -O SigBio-v0.1.zip
unzip SigBio-v0.1.zip
```

## Set Up
To install all the required R packages and organism database run `setup.R`

from terminal
```bash
cd sig-bio-shiny
Rscript inst/extra/setup.R
```

## Run the shiny app
```bash
Rscript app.R
```
Access the app in your browser with output URL.
