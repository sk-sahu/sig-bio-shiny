#' Running SigBio locally
#'
#' This function will run the SigBio shiny app locally
#' @return SigBio shinny app
#'
#' @export
run <- function() {
  appDir <- system.file("app", package = "EcoGEx")
  shiny::runApp(appDir, launch.browser = TRUE)
}
