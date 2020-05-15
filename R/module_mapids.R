mapids_ui <- function(id, label = "Mapped Ids") {
  ns <- NS(id)
  tagList(
   DT::dataTableOutput(ns("mapped_ids_table"))
  )
}

mapids_server <- function(input, output, session, mapped_ids) {
  mapped_ids <- mapped_ids
  output$mapped_ids_table <- DT::renderDataTable({
    as.data.frame(mapped_ids)
  })
}
