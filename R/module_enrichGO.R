enrichGO_ui <- function(id, label = "enrichGO") {
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel("All",
        plotOutput(ns("wego_plot")),
        #downloadButton(ns('download_tables', 'Download all tables')),
        uiOutput(ns("download_wego_plot_button"))
      ),
      tabPanel("Biological Process",
               tabsetPanel(
                 tabPanel("GO-Table",
                          DT::dataTableOutput(ns("table_go_bp"))),
                 tabPanel("Dot-Plot", 
                          plotOutput(ns("dot_plot_go_bp"))),
                 tabPanel("Enrich-Plot",
                          plotOutput(ns("enrich_plot_go_bp"))),
                 tabPanel("Cnet-Plot", 
                          plotOutput(ns("cnet_plot_go_bp")))
               )
      ),
      tabPanel("Cellular Component",
               tabsetPanel(
                 tabPanel("GO-Table",
                          DT::dataTableOutput(ns("table_go_cc"))),
                 tabPanel("Dot-Plot", 
                          plotOutput(ns("dot_plot_go_cc"))),
                 tabPanel("Enrich-Plot",
                          plotOutput(ns("enrich_plot_go_cc"))),
                 tabPanel("Cnet-Plot", 
                          plotOutput(ns("cnet_plot_go_cc")))
               )
      ),
      tabPanel("Molecular Functions",
               tabsetPanel(
                 tabPanel("GO-Table",
                          DT::dataTableOutput(ns("table_go_mf"))),
                 tabPanel("Dot-Plot", 
                          plotOutput(ns("dot_plot_go_mf"))),
                 tabPanel("Enrich-Plot",
                          plotOutput(ns("enrich_plot_go_mf"))),
                 tabPanel("Cnet-Plot", 
                          plotOutput(ns("cnet_plot_go_mf")))
               )
      )
    )
  )
}

enrichGO_server <- function(input, 
                            output, 
                            session, 
                            gene_list,
                            gene_list_with_fc,
                            entrez_ids, 
                            entrez_ids_with_fc_vector, 
                            org_pkg,
                            pval_cutoff, 
                            qval_cutoff) {
  
  gene_list <- gene_list
  gene_list_with_fc <- gene_list_with_fc
  entrez_ids_with_fc_vector <- entrez_ids_with_fc_vector
  entrez_ids <- entrez_ids
  org_pkg <- org_pkg
  pval_cutoff <- pval_cutoff
  qval_cutoff <- qval_cutoff
  
  enrichGO_res <- do_enrichGO(gene = entrez_ids, OrgDb = org_pkg,
                              pvalueCutoff = pval_cutoff, 
                              qvalueCutoff = qval_cutoff)
  go_bp <- enrichGO_res$go_bp
  go_cc <- enrichGO_res$go_cc
  go_mf <- enrichGO_res$go_mf
  
  # All Outputs ----
  # tables
  output$table_go_bp <- DT::renderDataTable({
    go_bp@result
  })
  output$table_go_cc <- DT::renderDataTable({
    go_cc@result
  })
  output$table_go_mf <- DT::renderDataTable({
    go_mf@result
  })
  
  # plots and their downloads ----
  # wego plot
  output$wego_plot <- renderPlot({
    wego_plot(BP=go_bp@result, CC=go_cc@result, MF=go_mf@result)
  })
  # wego plot download
  wego_plot_download <- reactive({
    wego_plot(BP=go_bp@result, CC=go_cc@result, MF=go_mf@result)
  })
  output$download_wego_plot <- downloadHandler(
    filename = function() {
      paste('wego_plot.png', sep='')
    },
    content = function(file) {
      ggplot2::ggsave(file, plot = wego_plot_download(), device = "png", width = 12, height = 10)
    }
  )
  # wego plot download button
  output$download_wego_plot_button <- renderUI({
    if(!is.null(gene_list)) {
      downloadButton("download_wego_plot", "Download Wego Plot")
    }
  })
  
  # dotplot
  output$dot_plot_go_bp <- renderPlot({
    enrichplot::dotplot(go_bp, showCategory=30)
  })
  output$dot_plot_go_cc <- renderPlot({
    enrichplot::dotplot(go_cc, showCategory=30)
  })
  output$dot_plot_go_mf <- renderPlot({
    enrichplot::dotplot(go_mf, showCategory=30)
  })
  
  # emapplot (Enrichment map)
  output$enrich_plot_go_bp <- renderPlot({
    enrichplot::emapplot(go_bp)
  })
  output$enrich_plot_go_cc <- renderPlot({
    enrichplot::emapplot(go_cc)
  })
  output$enrich_plot_go_mf <- renderPlot({
    enrichplot::emapplot(go_mf)
  })
  
  # if foldchange provided
  if (!is.null(gene_list_with_fc)){
    # cnetplot (Gene Concept Network)
    output$cnet_plot_go_bp <- renderPlot({
      enrichplot::cnetplot(go_bp, foldChange=entrez_ids_with_fc_vector, 
                           circular = TRUE, colorEdge = TRUE)
    })
    output$cnet_plot_go_cc <- renderPlot({
      enrichplot::cnetplot(go_cc, foldChange=entrez_ids_with_fc_vector, 
                           circular = TRUE, colorEdge = TRUE)
    })
    output$cnet_plot_go_mf <- renderPlot({
      enrichplot::cnetplot(go_mf, foldChange=entrez_ids_with_fc_vector, 
                           circular = TRUE, colorEdge = TRUE)
    })
  }else{
    output$cnet_plot_go_bp <- renderPlot({
      app_noFCmsgPlot()
    })
    output$cnet_plot_go_cc <- renderPlot({
      app_noFCmsgPlot()
    })
    output$cnet_plot_go_mf <- renderPlot({
      app_noFCmsgPlot()
    })
  }
}