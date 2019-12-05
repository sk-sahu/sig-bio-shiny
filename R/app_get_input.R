#' Takes user input and parse into list, which can be used by SigBio application.
#' 
#' @param gene_string This a string with only gene ids separated by new line character.
#'  Optionally it also accepts fold change (fc) next to each gene separated by coma.
#'  
#' @return This returns a list containing
#'   * Gene vector
#'   * Gene with fc. If fc not provided. this is NULL.
#'   
#' @examples 
#' input <- "ENSG00000196611,0.7
#' ENSG00000093009,1.2
#' ENSG00000109255,-0.3
#' ENSG00000134690,0.2
#' ENSG00000065328,1.7
#' ENSG00000117399,-0.5"
#' 
#' app_get_input(input)
#' 
#' @export
app_get_input <- function(gene_string){
  gene_list_split <- unlist(strsplit(gene_string, "\n"))
  gene_list_split <- unique(gene_list_split[gene_list_split != ""])
  
  if (all(grepl(",", gene_list_split)))
  {
    gene_list_split_2 <- unlist(strsplit(as.character(gene_list_split), ","))
    gene_with_fc <- matrix(gene_list_split_2, ncol = 2, byrow = TRUE)
    colnames(gene_with_fc) <- c("gene_list", "fc")
    gene_with_fc_df <- as.data.frame(gene_with_fc)
    gene_list_uprcase <- toupper(gene_with_fc_df$gene_list)
  } else{
    gene_with_fc_df <- NULL
    gene_list_uprcase <- toupper(gene_list_split)
  }
  return(list( "gene_list" = gene_list_uprcase, 
               "gene_list_with_fc" = gene_with_fc_df))
}

