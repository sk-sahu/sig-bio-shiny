#' @title Anot
#' Importing packages for the app
#' 
#' @import AnnotationHub
#' @import enrichplot
#' @import DT
#' @import pathview
#' @import dplyr
#' @export
NULL

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL

#' Custom message for Sig-Bio-Shiny-App
#' @param msg The message from app
#' @param ... Additional param to \code{\link[base]{paste}}
#' @export
sigbio_message <- function(msg, ...){
  message(paste("[SigBio]", msg))
}


#' No Fold Change message plot
#' 
#' This function is used by the app when no Fold Chnage is provided.
#' 
#' @return This returns a plot obejct with a message.
#'
#' @export
app_noFCmsgPlot <- function(){
  par(mar = c(0,0,0,0))
  plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
  text(x = 0.5, y = 0.5, paste("Insufficient data for this plot.\n",
                               "You need to provide foldchange for this."), 
       cex = 1.6, col = "black")
  par(mar = c(5, 4, 4, 2) + 0.1)
}