ui <- navbarPage("Sig-Bio", inverse = TRUE, collapsible = TRUE,
                 tabPanel("Gene Ontology",
                          sidebarLayout(
                            sidebarPanel(width = 3,
                                         # For text area input 
                                         textAreaInput("text_area_list", "Type/Paste gene list:", height = "130px", width = "200px",
                                                       value = "
ENSG00000012048
ENSG00000214049
ENSG00000204682"),
                                         actionButton("submit", label =  "Submit"),
                                         tags$hr(),
                                         
                                         # For file input
                                         fileInput("file1", "Or upload from a (.txt) file",
                                                   multiple = FALSE, width = "250px"),
                                         actionButton("submit_2", label =  "Submit Uploaded")
                            ),
                            mainPanel(
                              helpText("Note: It may take minutes. Check progress bar"),
                              tags$hr(),
                              #uiOutput("warning"),
                              #tags$hr(),
                              plotOutput("wego_plot"),
                              uiOutput("download_wego_plot_button"),
                              tabsetPanel(
                                tabPanel("Biological Process",
                                         DT::dataTableOutput(outputId = "table_go_bp")
                                ),
                                tabPanel("Cellular Process",
                                         DT::dataTableOutput(outputId = "table_go_cc")
                                ),
                                tabPanel("Cellular Process",
                                         DT::dataTableOutput(outputId = "table_go_mf")
                                )
                              )
                            ) # mainpanel end.
                          )
                 ),
                 
                 tabPanel("info",
                          verbatimTextOutput("sessioninfo")
                 )
)
    

# UI ends ----

# Server starts ----

org_pkg <- "org.Hs.eg.db" 
kegg_org_name <- "hsa"
gtf_type <- "ENSEMBL" # ensembl or refseq

suppressMessages(library(org_pkg, character.only = TRUE))
suppressMessages(library(AnnotationDbi))
suppressMessages(library(clusterProfiler))
suppressMessages(library(enrichplot))
suppressMessages(library(dplyr))
suppressMessages(library(ggplot2))
#suppressMessages(library(BiocParallel))
source("../../R/wego_plot.R")

server <- function(input, output) {
  
  # For submit of text area input
  observeEvent(input$submit, {
    
    # for progress bar
    withProgress(message = 'Steps:', value = 0, {
      
      incProgress(1/6, detail = paste("Starting...")) ##### Progress step 1
      
    output$warning <- renderUI({
      helpText("Note: It may take time for number of genes.")
    })
    
    #gene_list <- c("ENSG00000012048", "ENSG00000214049", "ENSG00000204682")
    gene_list <- input$text_area_list
    gene_list_split <- strsplit(gene_list, "\n")
    gene_list_split <- as.data.frame(gene_list_split)
    colnames(gene_list_split) <- "gene_list"
    gene_list_uprcase <- toupper(gene_list_split$gene_list)
    
    incProgress(2/6, detail = paste("Converting gene ids...")) ##### Progress step 2
    # Conver genelist to ENTREZIDs
    entrez_ids=mapIds(eval(parse(text = org_pkg)), as.character(gene_list_uprcase), 'ENTREZID', gtf_type)
    print("After Gene List converted into EntrezIDs (head): ")
    print(head(entrez_ids))
    
    incProgress(3/6, detail = paste("Doing Gene Ontology...")) ##### Progress step 3
    # Gene Ontology ----
    gene_ontology <- function(go_type = "BP"){
      go_obj <- clusterProfiler::enrichGO(entrez_ids, OrgDb = org_pkg,
                                      keyType = "ENTREZID",ont = go_type, 
                                      pvalueCutoff=1, qvalueCutoff=1)
      go_obj_2 <- clusterProfiler::setReadable(go_obj, OrgDb = org_pkg, keyType = "ENTREZID")
      return(go_obj_2)
    }
    go_bp <- gene_ontology(go_type = "BP")
    go_cc <- gene_ontology(go_type = "CC")
    go_mf <- gene_ontology(go_type = "MF")
    
    incProgress(4/6, detail = paste("Making Tables...")) ##### Progress step 4
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
    
    incProgress(5/6, detail = paste("Making plots...")) ##### Progress step 5
    # plots and their downloads ----
    # wego plot
    output$wego_plot <- renderPlot({
      wego_plot(BP=go_bp@result, CC=go_cc@result, MF=go_mf@result)
    })
    
    output$sessioninfo <- renderPrint({
      sessionInfo()
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
    
    incProgress(6/6, detail = paste("Finish.")) ##### Progress step 6
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