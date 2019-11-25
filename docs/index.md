# Sig-Bio-Shiny

This is a R shiny application to do significant biology on a set of genes.

This uses few of the Biocondutor packages underneath to give an interface for doing significant biology (Such as GO, KEGG, GSE analysis).

* [AnnotationHub] To get annotation information.
* [AnnotationDbi] To use some universal APIs for mapping data from OrgDb objects.
* [clusterProfiler] To perform most of the analysis.
* [enrichplot] To plot most plots.

[AnnotationDbi]: https://bioconductor.org/packages/release/bioc/html/AnnotationDbi.html
[AnnotationHub]: https://bioconductor.org/packages/release/bioc/html/AnnotationHub.html
[clusterProfiler]: https://bioconductor.org/packages/release/bioc/html/clusterProfiler.html
[clusterProfiler-book]: https://yulab-smu.github.io/clusterProfiler-book
[enrichplot]: https://bioconductor.org/packages/release/bioc/html/enrichplot.html

# Getting Started

1. [Requirement](#requirement)
2. [Download](#download)
3. [Set Up](#set-up)
4. [Run the shiny app](#run-the-shiny-app)
5. [FAQ](#faq)
6. [Reference](#reference)


## Requirement
Need atleast 8GB of RAM in the system

## Download
Clone using git
```
git clone https://github.com/sk-sahu/sig-bio-shiny.git
```
Download using wget
```
wget https://github.com/sk-sahu/sig-bio-shiny/archive/master.zip
unzip master.zip && mv sig-bio-shiny-master sig-bio-shiny
```

## Set Up
To install all the required R packages and organism database run `setup.R`

from terminal
```
cd sig-bio-shiny
Rscript setup.R
```

## Run the shiny app
```
Rscript app.R
```
Access the app in your browser with output URL.

## FAQ
[HELP](HELP.md)

## Reference
[here](reference.md)
