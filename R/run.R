#' Running SigBio locally
#'
#' This function will run the SigBio shiny app locally
#' @return SigBio shinny app
#'
#' @export
run <- function() {
  
  appDir <- system.file(".", package = "SigBio")
  
  shiny::runApp(appDir, launch.browser = TRUE)
}
