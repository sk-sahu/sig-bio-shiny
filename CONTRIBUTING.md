# Contributing Guide 

First of all thank you for your interest in contributing to this project :) 

If you want to fix/report any bugs or add an extra module then please follow developer notes bellow. This will help us to maintain a specific structure to the project.

## Developer Notes

> These are the initial notes. This section will be expanded more detail. Till then please feel free to contact if anything else required to know.

If you want to start right away - [Try this Rstudio-Cloud instace of this project](https://rstudio.cloud/project/1023160). You might need to git pull after login to get the latest dev branch. 

### Adding a new module

Try to keep `app.R` file minimal, only with essential lines of code. For each module, Server and UI functions should specify in a single R script (Example: `module_modulename.R`) and additional required functions for that modules should be in another file (Example: `module_modulename_utils.R`)

### Deploying

Whenever depolying to shinyapps.io - [Ref](https://support.bioconductor.org/p/107298/)

```R
options(repos = BiocManager::repositories()) 
```
