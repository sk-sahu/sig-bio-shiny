#' Title Help for SigBio Application 
#'
#' @return Path to Help.md file stored in the package.
#' @export
app_help <- function(){
  help_md <- base::system.file("inst/extdata/help.md", package = "SigBio")
  return(help_md)
}
