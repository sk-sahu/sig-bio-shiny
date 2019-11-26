suppressMessages(library(AnnotationDbi))
suppressMessages(library(reshape2))

mapIds_all <- function(genelist, org_pkg, gtf_type) {
  # Get the annotations ----
  genelist_ano <- AnnotationDbi::select(org_pkg, 
                                        keys = genelist, 
                                        columns = c("SYMBOL", "ENTREZID", "GENENAME"), 
                                        keytype = gtf_type)
  
  colnames(genelist_ano)[1] <- "gene_ids"
  # for GO terms
  genelist_ano_go <- AnnotationDbi::select(org_pkg, 
                                           keys = genelist, 
                                           column="GO", 
                                           keytype = gtf_type)
  
  genelist_ano_go[is.na(genelist_ano_go)] <- 'None'
  
  colnames(genelist_ano_go)[1] <- "gene_ids"
  
  genelist_ano_go_reshaped <- reshape2::dcast(genelist_ano_go[,-3], 
                                              gene_ids ~ ONTOLOGY,
                                              value.var="GO",
                                              fun.aggregate = function(x) paste0(x, collapse=",")
  )
  genelist_ano_go_reshaped$None <- NULL
  
  # for pathways
  genelist_ano_path <- AnnotationDbi::select(org_pkg, 
                                             keys = genelist, 
                                             column="PATH", 
                                             keytype = gtf_type)
  colnames(genelist_ano_path)[1] <- "gene_ids"
  
  genelist_ano_path_reshaped <- aggregate(. ~ gene_ids, 
                                          genelist_ano_path, 
                                          toString)
  
  final_ano <- Reduce(function(x, y) merge(x, y, all=TRUE), list(genelist_ano, genelist_ano_go_reshaped, genelist_ano_path_reshaped))
  
  return(final_ano)
}

