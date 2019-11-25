# test

library(AnnotationHub)

ah = AnnotationHub()

orgdb <- query(ah, "OrgDb")
selected_species <- orgdb$species[1]

selected_species_orgdb <- query(orgdb, selected_species)
orgdb_obj <- ah[[selected_species_orgdb$ah_id]]


# human test
org_pkg <- ah[["AH70563"]]
gene_list <- c("ENSG00000012048", "ENSG00000214049", "ENSG00000204682")

mapIds(org_pkg, as.character(gene_list), 'ENTREZID', "ENSEMBL")


selected_species_orgdb <- query(orgdb, "Bubalus bubalis")
orgdb_obj <- ah[[selected_species_orgdb$ah_id]]
keys(orgdb_obj, "REFSEQ") %>% head()
