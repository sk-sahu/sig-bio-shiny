#' Running SigBio locally
#'
#' This function will run the SigBio shiny app locally
#' @return SigBio shinny app
#'
#' @export
runApp <- function() {
  appDir <- system.file("app", package = "SigBio")
  shiny::runApp(appDir, launch.browser = TRUE)
}
