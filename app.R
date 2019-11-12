library(shiny)
ui <- navbarPage("Sig-Bio", inverse = TRUE, collapsible = TRUE,
                 tabPanel("Gene-Summary",
                          sidebarLayout(
                            sidebarPanel(width = 3,
                                         # For text area input 
                                         textAreaInput("text_area_list", "Gene list or Gene,Foldchnage list:", height = "130px", width = "200px",
                                                       value = "
ENSG00000049239,23.4013439616
ENSG00000074800,22.4639348847
ENSG00000171603,23.078462958
ENSG00000116285,23.091453082
ENSG00000116288,8.1240074204
ENSG00000074800,8.2065166175
ENSG00000142599,8.8824101153
ENSG00000171621,7.6509604768
ENSG00000162413,8.666196158
ENSG00000116273,7.4955643371
ENSG00000175756,7.5253928354
ENSG00000188976,7.2279606723
ENSG00000234619,8.303434686
ENSG00000007923,7.5280119186
ENSG00000232848,7.6211916231
ENSG00000049245,9.702377583
ENSG00000131584,8.0619989127
ENSG00000228463,-6.2285238309"),
                                         # get org from org_table.csv file
                                         org_table <- read.csv("data/org_table.csv", header = TRUE, row.names = 1),
                                         selectInput("org", "Organism:", 
                                                     choices=rownames(org_table)),
                                         hr(),
                                         helpText("List is taken from Bioconductor."),
                                         
                                         actionButton("submit", label =  "Submit"),
                                         tags$hr(),
                                         
                                         # For file input
                                         fileInput("file1", "Or upload from a (.txt) file",
                                                   multiple = FALSE, width = "250px"),
                                         actionButton("submit_2", label =  "Submit Uploaded")
                            ),
                            mainPanel(
                              helpText("Note: It may take minutes, depending upon the number of genes. Check progress bar"),
                              tags$hr(),
                              #uiOutput("warning"),
                              #tags$hr(),
                              textOutput("gene_number_info"),
                              tags$hr(),
                              DT::dataTableOutput(outputId = "entrez_ids_with_fc_table")
                            ) # mainpanel end.
                          )
                 ),
                 
                 tabPanel("Gene Ontology",
                          
                              plotOutput("wego_plot"),
                              uiOutput("download_wego_plot_button"),
                              tabsetPanel(
                                tabPanel("Biological Process",
                                         tabsetPanel(
                                           tabPanel("GO-Table",
                                                    DT::dataTableOutput(outputId = "table_go_bp")),
                                           tabPanel("Dot-Plot", 
                                                    plotOutput("dot_plot_go_bp")),
                                           tabPanel("Enrich-Plot",
                                                    plotOutput("enrich_plot_go_bp")),
                                           tabPanel("Cnet-Plot", 
                                                    plotOutput("cnet_plot_go_bp"))
                                         )
                                ),
                                tabPanel("Cellular Component",
                                         tabsetPanel(
                                           tabPanel("GO-Table",
                                                    DT::dataTableOutput(outputId = "table_go_cc")),
                                           tabPanel("Dot-Plot", 
                                                    plotOutput("dot_plot_go_cc")),
                                           tabPanel("Enrich-Plot",
                                                    plotOutput("enrich_plot_go_cc")),
                                           tabPanel("Cnet-Plot", 
                                                    plotOutput("cnet_plot_go_cc"))
                                         )
                                ),
                                tabPanel("Molecular Functions",
                                         tabsetPanel(
                                           tabPanel("GO-Table",
                                                    DT::dataTableOutput(outputId = "table_go_mf")),
                                           tabPanel("Dot-Plot", 
                                                    plotOutput("dot_plot_go_mf")),
                                           tabPanel("Enrich-Plot",
                                                    plotOutput("enrich_plot_go_mf")),
                                           tabPanel("Cnet-Plot", 
                                                    plotOutput("cnet_plot_go_mf"))
                                         )
                                )
                              )
                            

                 ),
                 # KEGG-Tab ----
                 tabPanel("KEGG",
                          tabsetPanel(
                            tabPanel("KEGG-Table",
                                     DT::dataTableOutput(outputId = "table_kegg")),
                            tabPanel("Dot-Plot", 
                                     plotOutput("dot_plot_kegg")),
                            tabPanel("Enrich-Plot",
                                     plotOutput("enrich_plot_kegg")),
                            tabPanel("Cnet-Plot", 
                                     plotOutput("cnet_plot_kegg")),
                            tabPanel("GSE-Plot", 
                                     plotOutput("pathway_gse_plot"))
                          )
                 ),
                 # Session-info-tab ----
                 tabPanel("Session info",
                          verbatimTextOutput("sessioninfo")
                 ),
                 tabPanel("Help",
                          includeMarkdown("HELP.md")
                 )
)
    

# UI ends ----

# Server starts ----

suppressMessages(library(AnnotationDbi))
suppressMessages(library(clusterProfiler))
suppressMessages(library(enrichplot))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
suppressMessages(library(DT))
#suppressMessages(library(BiocParallel))
source("R/wego_plot.R")
source("R/gse.R")

server <- function(input, output) {
  
  # For submit of text area input
  observeEvent(input$submit, {
    
    # for progress bar
    withProgress(message = 'Steps:', value = 0, {
      
      incProgress(1/6, detail = paste("Starting...")) ##### Progress step 1
      
      # based on user input
      #org_row <- org_table[org,]
      org_pkg <- as.character(org_table[input$org,]$org_pkg)
      kegg_org_name <- as.character(org_table[input$org,]$org_kegg)
      #org_pkg <- "org.Hs.eg.db" 
      #kegg_org_name <- "hsa"
      gtf_type <- "ENSEMBL" # ensembl or refseq
      suppressMessages(library(org_pkg, character.only = TRUE))
      
    output$warning <- renderUI({
      helpText("Note: It may take time for number of genes.")
    })
    
    # take gene list from text area and decode into a vector
    # if foldchange(fc) provided with coma(,) decode that in the if condition
    #gene_list <- c("ENSG00000012048", "ENSG00000214049", "ENSG00000204682")
    gene_list <- input$text_area_list
    gene_list_split <- unlist(strsplit(gene_list, "\n"))
    #gene_list_split <- as.data.frame(gene_list_split)
    gene_list_split <- unique(gene_list_split[gene_list_split != ""])
    
    if (all(grepl(",", gene_list_split)))
        {
          gene_list_split_2 <- unlist(strsplit(as.character(gene_list_split), ","))
          gene_with_fc <- matrix(gene_list_split_2, ncol = 2, byrow = TRUE)
          colnames(gene_with_fc) <- c("gene_list", "fc")
          gene_with_fc_df <- as.data.frame(gene_with_fc)
          gene_list_uprcase <- toupper(gene_with_fc_df$gene_list)
    } else{
      gene_list_uprcase <- toupper(gene_list_split)
    }
    
    # Conver genelist to ENTREZIDs
    entrez_ids=mapIds(eval(parse(text = org_pkg)), as.character(gene_list_uprcase), 'ENTREZID', gtf_type)
    print("After Gene List converted into EntrezIDs (head): ")
    print(head(entrez_ids))
    
    # If FoldChnage provided 
    # Create a geneList with genes and log2FC for few plots
    gene_with_fc_vector <- gene_with_fc_df[,2]
    names(gene_with_fc_vector) = as.character(gene_with_fc_df[,1])
    #gene_with_fc_vector = sort(gene_with_fc_vector, decreasing = TRUE)
    # Conver genelist in gene_with_fc_vector to ENTREZIDs
    entrez_ids_with_fc <- data.frame(entrez_ids, gene_with_fc_vector = gene_with_fc_vector[names(entrez_ids)])
    entrez_ids_with_fc_table <- entrez_ids_with_fc # for display only
    entrez_ids_with_fc_table$input_list <- names(entrez_ids) # for display only
    entrez_ids_with_fc <- na.omit(entrez_ids_with_fc)
    entrez_ids_with_fc_vector <- entrez_ids_with_fc[,2]
    names(entrez_ids_with_fc_vector) <- entrez_ids_with_fc[,1]
    #rownames(entrez_ids_with_fc) <- entrez_ids_with_fc[,1]
    #entrez_ids_with_fc <- entrez_ids_with_fc[,2]
    
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
    output$entrez_ids_with_fc_table <- DT::renderDataTable({
      datatable(entrez_ids_with_fc_table)
    })
    
    # Gene Ontology ----
    # small function
    gene_ontology <- function(go_type = "BP"){
      go_obj <- clusterProfiler::enrichGO(entrez_ids, OrgDb = org_pkg,
                                      keyType = "ENTREZID",ont = go_type, 
                                      pvalueCutoff=1, qvalueCutoff=1)
      go_obj_2 <- clusterProfiler::setReadable(go_obj, OrgDb = org_pkg, keyType = "ENTREZID")
      return(go_obj_2)
    }
    incProgress(2/6, detail = paste("Doing Gene Ontology for: BP...")) ##### Progress step 2
    go_bp <- gene_ontology(go_type = "BP")
    incProgress(3/6, detail = paste("Doing Gene Ontology for: CC...")) ##### Progress step 3
    go_cc <- gene_ontology(go_type = "CC")
    incProgress(4/6, detail = paste("Doing Gene Ontology for: MF...")) ##### Progress step 4
    go_mf <- gene_ontology(go_type = "MF")
    
    #incProgress(4/6, detail = paste("Making Tables...")) ##### Progress step 4
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
    
    #incProgress(5/6, detail = paste("Making plots...")) ##### Progress step 5
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
        ggsave(file, plot = wego_plot_download(), device = "png", width = 12, height = 10)
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
      dotplot(go_bp, showCategory=30)
    })
    output$dot_plot_go_cc <- renderPlot({
      dotplot(go_cc, showCategory=30)
    })
    output$dot_plot_go_mf <- renderPlot({
      dotplot(go_mf, showCategory=30)
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
    
    # if foldchnage not provided give this message
    message_plot <- function(){
      par(mar = c(0,0,0,0))
      plot(c(0, 1), c(0, 1), ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
      text(x = 0.5, y = 0.5, paste("Insufficient data for this plot.\n",
                                   "You need to provide foldchange for this."), 
           cex = 1.6, col = "black")
      par(mar = c(5, 4, 4, 2) + 0.1)
    }
    # if foldchange provided
    if (all(grepl(",", gene_list_split))){
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
        message_plot()
      })
      output$cnet_plot_go_cc <- renderPlot({
        message_plot()
      })
      output$cnet_plot_go_mf <- renderPlot({
        message_plot()
      })
    }
    
    # KEGG ----
    incProgress(5/6, detail = paste("Doing KEGG...")) ##### Progress step 5
    kegg <- enrichKEGG(entrez_ids, 
                       organism = kegg_org_name, 
                       pvalueCutoff=0.05, 
                       pAdjustMethod="BH", 
                       qvalueCutoff=0.1)
    kegg_2 <- setReadable(kegg, OrgDb = org_pkg, keyType = "ENTREZID")
    # kegg-table 
    output$table_kegg <- DT::renderDataTable({
      kegg_2@result
    })
    # kegg-dotplot
    output$dot_plot_kegg <- renderPlot({
      dotplot(kegg_2, showCategory=30)
    })
    # kegg-emapplot (Enrichment map)
    output$enrich_plot_kegg <- renderPlot({
      enrichplot::emapplot(kegg_2)
    })
    if (all(grepl(",", gene_list_split))){
      # cnetplot (Gene Concept Network)
      output$cnet_plot_kegg <- renderPlot({
        enrichplot::cnetplot(kegg_2, foldChange=entrez_ids_with_fc_vector, 
                             circular = TRUE, colorEdge = TRUE)
      })
      output$pathway_gse_plot <- renderPlot({
        # gse-pathway
        pathway_gse(id_with_fc_list = entrez_ids_with_fc_vector)
      })
      # gse-pathway
      pathway_gse()
    }else{
      output$cnet_plot_kegg <- renderPlot({
        message_plot()
      })
    }
    
    # gse-pathway
    pathway_gse()
    
    incProgress(6/6, detail = paste("Finish.")) ##### Progress step 6
    
    output$sessioninfo <- renderPrint({
      sessionInfo()
    })
    
    }) # withProgress ends here
  }) # textbox area submit button observeEvent() end.
  
  # For submit of file upload
  observeEvent(input$submit_2, {
    
    validate(
      need(input$file1 != "", "Please upload a file")
    )
    
    gene_sortlist <- input$file1
    gene_ids <- read.csv(gene_sortlist$datapath, header = FALSE)
    gene_ids_uprcase <- toupper(gene_ids$V1)
    
  })
}

# Run the application 
shinyApp(ui = ui, server = server)