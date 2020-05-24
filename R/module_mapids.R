mapids_ui <- function(id, label = "Mapped Ids") {
  ns <- NS(id)
  tagList(
   DT::dataTableOutput(ns("mapped_ids_table"))
  )
}

mapids_server <- function(input, output, session, gene_list_uprcase, org_pkg, gtf_type) {
  mapped_ids <- SigBio:::do_selectIds(genelist = as.character(gene_list_uprcase),
                             org_pkg = org_pkg,
                             gtf_type = gtf_type)
  output$mapped_ids_table <- DT::renderDataTable({
    as.data.frame(mapped_ids)
  })
}
