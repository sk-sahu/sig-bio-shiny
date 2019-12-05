#' @import clusterProfiler
#' @export
do_enrichGO <- function(...){
  go_obj <- list()
  go_obj_2 <- list()
  dots <- list(...)
  for(ont in c("BP", "CC", "MF")){
    sigbio_message(paste0("Doing enrichGO for: ", ont))
    go_obj[[ont]] <- clusterProfiler::enrichGO(keyType = "ENTREZID",ont = ont, ...)
    #print(go_obj[ont])
    sigbio_message("Converting entrezids to readable gene ids (gene symbles) ")
    go_obj_2[[ont]] <- clusterProfiler::setReadable(go_obj[[ont]], OrgDb = dots$OrgDb, keyType = "ENTREZID")
  }
  return(list("go_bp" = go_obj_2$BP,
              "go_cc" = go_obj_2$CC,
              "go_mf" = go_obj_2$MF))
}

