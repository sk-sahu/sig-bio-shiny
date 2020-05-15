#' select all
#' 
#' Wrapper funtion to \code{\link[AnnotationDbi]{select}}
#' 
#' @param org_pkg An AnnotationHub OrgDb object
#' @param genelist A vector with list of input genes
#' @param gtf_type Input gene type
#' 
#' @return A dataframe with selected IDs 
#' 
#' @import AnnotationDbi
#' @import reshape2
#' @importFrom stats aggregate
#' @export
do_selectIds <- function(genelist, org_pkg, gtf_type) {
  # Get the annotations ----
  genelist_ano <- AnnotationDbi::select(org_pkg, 
                                        keys = genelist, 
                                        columns = c("SYMBOL", "ENTREZID", "GENENAME"), 
                                        keytype = gtf_type)
  
  colnames(genelist_ano)[1] <- "gene_ids"
  # for GO terms
  genelist_ano_go <- AnnotationDbi::select(org_pkg, 
                                           keys = genelist, 
                                           columns = c("GO","ONTOLOGY"), 
                                           keytype = gtf_type)
  
  genelist_ano_go[is.na(genelist_ano_go)] <- 'None'
  
  colnames(genelist_ano_go)[1] <- "gene_ids"
  
  #casting_formula = sprintf("%s ~ %s", genelist_ano_go$gene_ids, genelist_ano_go$ONTOLOGY)
                            
  genelist_ano_go_reshaped <- reshape2::dcast(genelist_ano_go, 
                                              formula =  "gene_ids ~ ONTOLOGY",
                                              value.var="GO",
                                              fun.aggregate = function(x) paste0(x, collapse=",")
  )
  genelist_ano_go_reshaped$None <- NULL
  
  # for pathways
  if ( "PATH" %in% columns(org_pkg)){
    genelist_ano_path <- AnnotationDbi::select(org_pkg, 
                                               keys = genelist, 
                                               column="PATH", 
                                               keytype = gtf_type)
    colnames(genelist_ano_path)[1] <- "gene_ids"
    
    genelist_ano_path_reshaped <- aggregate(. ~ gene_ids, 
                                            genelist_ano_path, 
                                            toString)
  }else{
    genelist_ano_path_reshaped <- NULL
  }
  
  if (!is.null(genelist_ano_path_reshaped)){
    all_ano_list <- list(genelist_ano, genelist_ano_go_reshaped, genelist_ano_path_reshaped)
  } else{
    all_ano_list <- list(genelist_ano, genelist_ano_go_reshaped)
  }
  
  final_ano <- Reduce(function(x, y) merge(x, y, all=TRUE), all_ano_list)
  
  return(final_ano)
}

#  for bub
# suppressMessages(library(AnnotationHub))
# suppressMessages(library(AnnotationDbi))
# ah = AnnotationHub()
# genelist <- as.character(c("XM_025264254.1",
#                            "XM_006064447.2",
#                            "XM_025265616.1"))
# genelist <- as.character(c("NM_001290732.1",
#                            "NM_001290832.1",
#                            "NM_001290833.1",
#                            "NM_001290835.1",
#                            "NM_001290838.1",
#                            "NM_001290839.1"))
# org_pkg <- ah[["AH72312"]]
# gtf_type = "REFSEQ"
# mapped <- do_selectIds(genelist = as.character(genelist), org_pkg = org_pkg, gtf_type = gtf_type)
# 
# # for human
# org_pkg <- ah[["AH70572"]]
# genelist <- as.character(c("ENSG00000012048", "ENSG00000214049", "ENSG00000204682"))
# gtf_type = "ENSEMBL"
# mapped <- do_selectIds(genelist = as.character(genelist), org_pkg = org_pkg, gtf_type = gtf_type)
