enrichKEGG_ui <- function(id, label = "enrichKEGG") {
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel("KEGG-Table",
               DT::dataTableOutput(ns("table_kegg"))),
      tabPanel("Dot-Plot", 
               plotOutput(ns("dot_plot_kegg"))),
      tabPanel("Enrich-Plot",
               plotOutput(ns("enrich_plot_kegg"))),
      tabPanel("Cnet-Plot", 
               plotOutput(ns("cnet_plot_kegg"))),
      tabPanel("GSE-Plot", 
               plotOutput(ns("pathway_gse_plot"))),
      tabPanel("Path-View", 
               uiOutput(ns("pathview_dropdown")),
               plotOutput(ns("pathview_plot_in_ui")))
    )
  )
}

enrichKEGG_server <- function(input, 
                            output, 
                            session, 
                            gene_list_with_fc,
                            entrez_ids, 
                            entrez_ids_with_fc_vector,
                            entrez_ids_with_fc,
                            org_pkg,
                            kegg_org_name,
                            pval_cutoff, 
                            qval_cutoff) {
  
  gene_list_with_fc <- gene_list_with_fc
  entrez_ids <- entrez_ids
  entrez_ids_with_fc_vector <- entrez_ids_with_fc_vector
  entrez_ids_with_fc <- entrez_ids_with_fc
  org_pkg <- org_pkg
  kegg_org_name <- kegg_org_name
  pval_cutoff <- pval_cutoff
  qval_cutoff <- qval_cutoff
  
  kegg <- clusterProfiler::enrichKEGG(entrez_ids, 
                                      organism = kegg_org_name, 
                                      pvalueCutoff=pval_cutoff, 
                                      pAdjustMethod="BH", 
                                      qvalueCutoff=qval_cutoff)
  kegg_2 <- clusterProfiler::setReadable(kegg, OrgDb = org_pkg, keyType = "ENTREZID")
  # kegg-table 
  output$table_kegg <- DT::renderDataTable({
    kegg_2@result
  })
  
  # UI from server
  ns <- session$ns
  if (!is.null(gene_list_with_fc)){
    output$pathview_dropdown <- renderUI({
      selectInput(ns("path_id"), label = "Select from enriched pathway",
                  choices = kegg_2@result$ID)
    })
    
    # data preparation for next step pathview plot
    gene_data <- entrez_ids_with_fc$gene_with_fc_vector %>% as.data.frame()
    rownames(gene_data) <- entrez_ids_with_fc$entrez_ids
    
    observe({
      pathview_plot <- pathview::pathview(gene.data  = gene_data,
                                          pathway.id = input$path_id,
                                          species    = kegg_org_name,
                                          kegg.dir = tempdir()
      )
      # get the png and render
      output$pathview_plot_in_ui <- renderImage({
        filename <- normalizePath(file.path('.',
                                            paste(input$path_id, '.pathview.png', sep='')))
        list(src = filename)
      }, deleteFile = FALSE)
    })
  }
  
  # kegg-dotplot
  output$dot_plot_kegg <- renderPlot({
    enrichplot::dotplot(kegg_2, showCategory=30)
  })
  # kegg-emapplot (Enrichment map)ac
  output$enrich_plot_kegg <- renderPlot({
    enrichplot::emapplot(kegg_2)
  })
  if (!is.null(gene_list_with_fc)){
    # cnetplot (Gene Concept Network)
    output$cnet_plot_kegg <- renderPlot({
      enrichplot::cnetplot(kegg_2, foldChange=entrez_ids_with_fc_vector, 
                           circular = TRUE, colorEdge = TRUE)
    })
    output$pathway_gse_plot <- renderPlot({
      # gse-pathway
      do_gseKEGG_plot(id_with_fc_list = entrez_ids_with_fc_vector, 
                      organism = kegg_org_name,
                      pval = pval_cutoff)
    })
  }else{
    output$cnet_plot_kegg <- renderPlot({
      app_noFCmsgPlot()
    })
    output$pathway_gse_plot <- renderPlot({
      app_noFCmsgPlot()
    })
  }
}