#' Get organism
#' 
#' Fetch all the organism list using AnnotationHub interface and KEGG rest API
#' 
#' @import AnnotationHub
#' 
#' @export
app_getOrg <- function(){
  sigbio_message("Fetching AnnotationHub database...")
  ah = AnnotationHub::AnnotationHub()
  orgdb <- AnnotationHub::query(ah, "OrgDb")
  sigbio_message("KEGG database organism list API fetch...") 
  kegg_org_list <- SigBio::kegg_link()
  org <- list( "ah_obj" = ah,
               "ah_orgdb" = orgdb,
               "kegg_org_list" = kegg_org_list)
  return(org)
}
