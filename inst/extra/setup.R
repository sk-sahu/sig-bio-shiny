# Setup
if_not_install <- function(pkg_list, source = "cran"){
  new.packages <- pkg_list[!(pkg_list %in% installed.packages()[,"Package"])]
  if(length(new.packages)){
    if(source == "bioc"){
      BiocManager::install(new.packages)
    }
    else if(source == "github"){
      devtools::install_github(new.packages)
    }
    else{
      install.packages(new.packages, repos = "https://cloud.r-project.org")
    }
  }
}

# install required cran packages
list_of_cran_pkgs <- c("shiny","rmarkdown","dplyr", "ggstance",
                       "ggplot2", "forcats","DT", "BiocManager", "devtools")
if_not_install(pkg_list = list_of_cran_pkgs)

list_of_bioc_pkgs <- c("AnnotationHub", "AnnotationDbi", "clusterProfiler", 
                       "enrichplot", "ReactomePA")
if_not_install(pkg_list = list_of_bioc_pkgs, source = "bioc")

# for YuLab-SMU/clusterProfiler.dplyr
list_of_github_pkg <- c("YuLab-SMU/clusterProfiler.dplyr")
if_not_install(pkg_list = list_of_github_pkg, source = "github")
