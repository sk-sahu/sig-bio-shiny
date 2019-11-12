# gene set enrichment

library(ReactomePA)
library(forcats)
library(ggplot2)
library(ggstance)
library(enrichplot)
library(clusterProfiler.dplyr)

# same as geneList
# entrez_ids_with_fc_vector = geneList is a object from DOSE pkg
pathway_gse <- function(id_with_fc_list = entrez_ids_with_fc_vector, organism = "human"){
  list_for_gse <- as.numeric(levels(id_with_fc_list))[id_with_fc_list]
  names(list_for_gse) <- names(id_with_fc_list)
  gse_pathway <- gsePathway(sort(list_for_gse, decreasing = TRUE), organism = organism)
  
  # test: geneList is a object from DOSE pkg
  #gse_pathway <- gsePathway(geneList)
  
  y <- arrange(gse_pathway@result, abs(NES)) %>% 
    group_by(sign(NES)) %>% 
    slice(1:5)
  
  ggplot(y, aes(NES, fct_reorder(Description, NES), fill=qvalues), showCategory=10) + 
    geom_barh(stat='identity') + 
    scale_fill_continuous(low='red', high='blue', guide=guide_colorbar(reverse=TRUE)) + 
    theme_minimal() + xlab("Normalized Enrichment Score (NES)") + ylab(NULL)
}

