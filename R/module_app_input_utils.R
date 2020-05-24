#' Parse text area
#' 
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
#' app_parse_textarea(input)
#' 
#' @export
app_parse_textarea <- function(gene_string){
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


#' Get organism
#' 
#' Fetch all the organism list using AnnotationHub interface and KEGG rest API
#' 
#' @import AnnotationHub
#' 
#' @export
app_getOrg <- function(){
  SigBio:::sigbio_message("Fetching AnnotationHub database...")
  ah = AnnotationHub::AnnotationHub()
  orgdb <- AnnotationHub::query(ah, "OrgDb")
  SigBio:::sigbio_message("KEGG database organism list API fetch...") 
  kegg_org_list <- SigBio::kegg_link()
  org <- list( "ah_obj" = ah,
               "ah_orgdb" = orgdb,
               "kegg_org_list" = kegg_org_list)
  return(org)
}


#' Call KEGG rest API
#' 
#' @param rest_url KEGG rest url Endpoint.(https://www.kegg.jp/kegg/rest/keggapi.html)
#' @import magrittr
#' @export
kegg_rest <- function(rest_url) {
  content <- tryCatch(suppressWarnings(readLines(rest_url)), error=function(e) NULL)
  if (is.null(content))
    return(content)
  
  content %<>% strsplit(., "\t") %>% do.call('rbind', .)
  res <- data.frame(id=content[,1],
                    org_code=content[,2],
                    org_name=content[,3])
  return(res)
}

#' Links to kegg rest api for org list
#' @export
kegg_link <- function(){
  url <- paste0("http://rest.kegg.jp/list/organism", collapse="")
  kegg_rest(url)
}

#kegg_list <- kegg_link()



# convert to entrez ID
convert_entrez_check <- function(gene_list_uprcase, gene_with_fc_df, gtf_type, org_pkg ){
  
  entrez_ids <- AnnotationDbi::mapIds(org_pkg, as.character(gene_list_uprcase), 'ENTREZID', gtf_type)
  
  print("After Gene List converted into EntrezIDs (head): ")
  print(head(entrez_ids))
  
  # If FoldChnage provided 
  # Create a geneList with genes and log2FC for few plots
  if (!is.null(gene_with_fc_df))
  {
    gene_with_fc_vector <- gene_with_fc_df[,2]
    names(gene_with_fc_vector) = as.character(gene_with_fc_df[,1])
    #gene_with_fc_vector = sort(gene_with_fc_vector, decreasing = TRUE)
    # Conver genelist in gene_with_fc_vector to ENTREZIDs
    entrez_ids_with_fc <- data.frame(entrez_ids, gene_with_fc_vector = gene_with_fc_vector[names(entrez_ids)])
    entrez_ids_with_fc_table <- entrez_ids_with_fc # for display only
    entrez_ids_with_fc_table$input_list <- names(entrez_ids) # for display only
    entrez_ids_with_fc <- na.omit(entrez_ids_with_fc)
    entrez_ids_with_fc_vector <- entrez_ids_with_fc[,2]
    names(entrez_ids_with_fc_vector) <- entrez_ids_with_fc[,1]
  }
  
  return(
    list(
      entrez_ids = entrez_ids,
      entrez_ids_with_fc = entrez_ids_with_fc,
      entrez_ids_with_fc_vector = entrez_ids_with_fc_vector
    )
  )
}