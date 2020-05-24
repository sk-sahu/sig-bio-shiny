app_input_validate_ui <- function(id, label = "enrichGO") {
  ns <- NS(id)
  tagList(
    textOutput(ns("gene_number_info")),
    DT::dataTableOutput(ns("gene_number_info_table"))
  )
}

app_input_validate_server <- function(input, 
                            output, 
                            session,
                            input_org,
                            input_orgdb,
                            input_ah,
                            input_kegg_org_code,
                            input_id_type,
                            input_text_area_list){
  # get org information based on user input
  selected_species <- as.character(input_org)
  SigBio:::sigbio_message(paste("Selected org is - ", selected_species))
  selected_species_orgdb <- AnnotationHub::query(input_orgdb, selected_species)
  SigBio:::sigbio_message("Selected org AnnotationHub ID - ", selected_species_orgdb$ah_id[1])
  org_pkg <- input_ah[[selected_species_orgdb$ah_id[1]]]
  kegg_org_name <- input_kegg_org_code
  gtf_type <- input_id_type # ensembl or refseq
  
  # get user input and parse
  text_area_input <- SigBio:::app_parse_textarea(input_text_area_list)
  gene_list_uprcase <- text_area_input$gene_list
  gene_with_fc_df <- text_area_input$gene_list_with_fc
  
  ############ Entrez ID convertion starts #########
  SigBio:::sigbio_message("Converting input gene list to entrez ids...")
  
  converted_id <- convert_entrez_check(gene_list_uprcase = gene_list_uprcase,
                                       gene_with_fc_df = gene_with_fc_df,
                                       gtf_type = gtf_type,
                                       org_pkg = org_pkg)
  
  entrez_ids <- converted_id$entrez_ids
  entrez_ids_with_fc <- converted_id$entrez_ids_with_fc
  entrez_ids_with_fc_vector <- converted_id$entrez_ids_with_fc_vector
  
  # for message in main tab
  input_gene_number <- length(gene_list_uprcase)
  proceed_gene_number <- length(na.omit(entrez_ids))
  output$gene_number_info <- renderText({ 
    paste("Done!",
          "Total Number of Input genes: ", input_gene_number,
          "| Total Number of proceed further: ", proceed_gene_number,
          "| Reason could be entrez id not found. Check the table bellow.",
          sep="\n")
  })
  # message for main pannel
  output$gene_number_info_table <- DT::renderDataTable({
    DT::datatable(cbind(gene_list_uprcase, entrez_ids))
  })
  
  ############ Entrez ID convertion end #########

  return(
    list(
      gene_list_uprcase = gene_list_uprcase,
      gene_with_fc_df = gene_with_fc_df,
      entrez_ids = entrez_ids,
      entrez_ids_with_fc = entrez_ids_with_fc,
      entrez_ids_with_fc_vector = entrez_ids_with_fc_vector,
      org_pkg = org_pkg,
      kegg_org_name = kegg_org_name,
      gtf_type = gtf_type
    )
  )
}