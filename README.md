# sig-bio-shiny <img src="inst/figures/sigbio_logo.png" align="right" alt="" width="120" />

<!-- badges: start -->
  [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  [![GitHub release (latest by date)](https://img.shields.io/github/v/release/sk-sahu/sig-bio-shiny)](https://github.com/sk-sahu/sig-bio-shiny/releases)
  [![Build Status](https://travis-ci.org/sk-sahu/sig-bio-shiny.svg?branch=master)](https://travis-ci.org/sk-sahu/sig-bio-shiny)
  [![CircleCI](https://circleci.com/gh/sk-sahu/sig-bio-shiny.svg?style=svg)](https://circleci.com/gh/sk-sahu/sig-bio-shiny)
  [![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/sudosk/sig-bio-shiny)](https://hub.docker.com/repository/docker/sudosk/sig-bio-shiny/builds)
[![R build status](https://github.com/sk-sahu/sig-bio-shiny/workflows/R-CMD-check/badge.svg)](https://github.com/sk-sahu/sig-bio-shiny/actions?workflow=R-CMD-check)
[![DOI](https://zenodo.org/badge/220482361.svg)](https://zenodo.org/badge/latestdoi/220482361)
<!-- badges: end -->

An application suite/interface for doing Significant Biology on a set of Gene

* [Demo](#demo)
* [Introduction](#introduction)
* [DataFlow](#dataflow)
* [Disclaimer](#disclaimer)
* [Requirement](#requirements)
* [Download](#download)
* [Run the shiny app](#run-the-shiny-app)

## Demo
For now this application requires atleast 4 GB of system memory. So couldn't able to host on shinyapps.io but instead with generous help of Rstudio now this project Rstudio Cloud instace is 4GB. So you can simply login with follwing project link, Open the `sig-bio-shiny.R` and click on Run App button. 

### [Try SigBio-Shiny in Rstudio-Cloud](https://rstudio.cloud/project/1023160)

Bellow is a screen recoding of what can be done with the SigBio interface - 

![](sigbio-v0.2.1.gif)

## Introduction
**Significant Biology** is an important step of any high-throughput sequence analysis. Once you mapped and/or assembled sequenced reads followed by feature(gene/isoform) quantification and/or diffrential analysis you will end up with set of genes. Quickly exploring those genes from diffrent aspect what gives an idea about the Biology they involved in. Here comes this **SigBio** Shiny application interface. This is platform where with a set of genes you can do **Gene mapping Annotation, Enrichment Analysis of Gene Ontology (GO), KEGG Pathway and many things (which will be discussed soon).**

Completely made using R and Bioconductor. No manual database dump required, which make deployment simple with a single R Script. It takes full advantage of AnnotationHub package to get annotation for the selected organism and do enrichment analysis on top of it using ClusterProfiler.  AnnotationHub makes sure you always get the lastest annotation from public databases. 

## DataFlow
![](https://vectr.com/sksahu/cIcdhZe42.png?width=640&height=640&select=cIcdhZe42page0)

## Disclaimer
sig-bio-shiny shiny application along with the SigBio R package is an open source effort and distributed under [MIT license](https://opensource.org/licenses/MIT). This uses KEGG data for few tasks, which is free for Academic uses but other uses may require a license agreement (In details at [KEGG Website](https://www.kegg.jp/kegg/legal.html)). By using this application you follow the respective tool licenses. Any developer involved in this DO NOT warrant nor responsible for any legal issues.

## Requirements
R >= 3.5

## Download
First you need to install the SigBio package which have all the APIs required for most functionality in the shiny app.

Download a specific version of the app using wget from terminal
```bash
wget https://raw.githubusercontent.com/sk-sahu/sig-bio-shiny/master/app.R -O sig-bio-shiny-app.R
```
On the first time of running This will download and install all the required dependency.

If application lunch fails, [FAQ](#faq) 

## Run the shiny app
From your terminal
```bash
Rscript sig-bio-shiny-app.R
```
Access the app in your browser with output URL.

### Run with docker
```bash
docker pull sudosk/sig-bio-shiny:latest
docker run --user shiny --rm -p 80:3838 sudosk/sig-bio-shiny:latest
```
Accessed app in a browser at http://127.0.0.1

## FAQ
If application lunch fails, you need to install the SigBio package manually which have all the APIs required for most functionality in this shiny app. In R
```r
if (!require(remotes)) { install.packages("remotes") }
  remotes::install_github("sk-sahu/sig-bio-shiny")
```
