#' Do pathway GSE (gene set enrichment) Plot
#' 
#' Wraper function to \code{\link[clusterProfiler]{gseKEGG}} with some extra functionality
#' specific to application. 
#' 
#' @param id_with_fc_list A vector with gene_ids and their fold change. Much like geneList from DOSE pakage
#' @param organism A kegg org short name
#' @param pval P-value cut-off
#' 
#' @return A GSE plot
#' 
#' @import magrittr
#' @import clusterProfiler
#' @import clusterProfiler.dplyr
#' @importFrom forcats fct_reorder
#' @importFrom ggstance geom_barh
#' @importFrom ggplot2 ggplot
#'
#' @export
#load("data/gse_test.RData")
# same as geneList
# entrez_ids_with_fc_vector = geneList is a object from DOSE pkg
do_gseKEGG_plot <- function(id_with_fc_list, 
                        organism = "hsa",
                        pval = "0.05"){
  list_for_gse <- as.numeric(levels(id_with_fc_list))[id_with_fc_list]
  names(list_for_gse) <- names(id_with_fc_list)
  gse_pathway <- gseKEGG(sort(list_for_gse, decreasing = TRUE), 
                            organism = organism,
                            pvalueCutoff = pval,
                            )
  
  # test: geneList is a object from DOSE pkg
  #gse_pathway <- gsePathway(geneList)
  
  y <- clusterProfiler.dplyr::arrange(gse_pathway@result, abs(NES)) %>% 
    clusterProfiler.dplyr::group_by(sign(NES)) %>% 
    clusterProfiler.dplyr::slice(1:5)
  
  ggplot(y, aes(NES, forcats::fct_reorder(Description, NES), fill=qvalues), showCategory=10) + 
    ggstance::geom_barh(stat='identity') + 
    scale_fill_continuous(low='red', high='blue', guide=guide_colorbar(reverse=TRUE)) + 
    theme_minimal() + xlab("Normalized Enrichment Score (NES)") + ylab(NULL)
}

