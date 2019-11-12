# Help
***

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
Access the app in your browser - 
http://127.0.0.1:3138/

## Input 
Input in text area must be **ENSEMBL** gene ID (Support of RefSeq IDs will be added).

If you providing fold change (which is **optional**, only required for certain plots), include them **separate by a comma**.

For example (GeneIDs with fold change)
```
ENSG00000012048,4.6
ENSG00000214049,-3.7
ENSG00000204682,2.5
```
**Browse file (not working for now, under testing.)**

## Furthere Issue/Quries
Ask them here - https://github.com/sk-sahu/sig-bio-shiny/issues/new