# install all the org.db 
org_table <- org_table <- read.csv("data/org_table.csv", header = TRUE, row.names = 1)
BiocManager::install(as.character(org_table$org_pkg))