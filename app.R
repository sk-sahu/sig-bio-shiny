# Sig-Bio-Shiny Application
# Home Page - http://sk-sahu.github.io/sig-bio-shiny/
# Source Code - https://github.com/sk-sahu/sig-bio-shiny
# Developed and maintain by Sangram Keshari Sahu (https://sksahu.net)

sigbio.version='0.2.1'

message("Running Sig-Bio-Shiny v", sigbio.version, " | ",date())
message("Checking if SigBio v", sigbio.version, " Package is installed...")

if("SigBio" %in% rownames(installed.packages()) && packageVersion("SigBio") != sigbio.version){
  options(repos = c(CRAN = "http://cran.rstudio.com"))
  if (!require(remotes)) { install.packages("remotes") }
  remotes::install_github("sk-sahu/sig-bio-shiny", 
                          ref = paste0("v", sigbio.version))
}

suppressMessages(library(SigBio))

sigbio_message("Starting the application...")
# Load organisms
org <- SigBio::load_org()
ah <- org$ah_obj
orgdb <- org$ah_orgdb
kegg_list <- org$kegg_org_list

library(shiny)

ui <- navbarPage(paste0("Sig-Bio v",sigbio.version), inverse = TRUE, collapsible = TRUE,
                 tabPanel("Gene-Summary",
                          sidebarLayout(
                            sidebarPanel(width = 3,
                                         # For text area input 
                                         textAreaInput("text_area_list", "Gene list or Gene,Foldchnage list:", 
                                                       height = "150px", width = "230px",
                                                       value = "
ENSG00000196611,0.7
ENSG00000093009,1.2
ENSG00000109255,-0.3
ENSG00000134690,0.2
ENSG00000065328,1.7
ENSG00000117399,-0.5"),
                                         # get org from org_table object
                                         
                                         selectInput("id_type", label = "Input gene-id Type:", selected = "ENSEMBL",
                                                     choices=c("ENSEMBL", "REFSEQ", "ENTREZID")),
                                         selectInput("org", label = "Organism:", selected = "Homo sapiens",
                                                     choices=orgdb$species),
                                         selectInput("kegg_org_code", label = "KEGG Organism Short Name:", selected = "hsa",
                                                     choices=kegg_list$org_code),
                                         helpText("Get your KEGG Organism short name from here - https://www.genome.jp/kegg/catalog/org_list.html"),
                                         numericInput("pval_cutoff", label = "pvalue-CutOff", 
                                                      value = 1, min=0.001, max=1),
                                         numericInput("qval_cutoff", label = "qvalue-CutOff", 
                                                      value = 1, min=0.001, max=1),
                                         hr(),
                                         helpText("After submit it may take minutes. Check Progress bar in right
                                                  side cornor"),
                                         
                                         actionButton("submit", label =  "Submit",
                                                      icon = icon("angle-double-right")),
                                         tags$hr(),
                                         
                                         # For file input
                                         # fileInput("file1", "Or upload from a (.txt) file",
                                         #           multiple = FALSE, width = "250px"),
                                         # actionButton("submit_2", label =  "Submit Uploaded")
                            ),
                            mainPanel(
                              helpText("Note: It may take minutes, depending upon the number of genes. Check progress bar"),
                              tags$hr(),
                              #uiOutput("warning"),
                              textOutput("gene_number_info"),
                              tags$hr(),
                              DT::dataTableOutput(outputId = "gene_number_info_table")
                            ) # mainpanel end.
                          )
                 ),
                 
                 # mapped ids
                 tabPanel("Mapped Ids",
                            DT::dataTableOutput(outputId = "mapped_ids_table")
                 ),
                 
                 # gene ontology
                 tabPanel("Gene Ontology",
                          
                              plotOutput("wego_plot"),
                              downloadButton('download_tables', 'Download all tables'),
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
                                     plotOutput("pathway_gse_plot")),
                            tabPanel("Path-View", 
                                     uiOutput("pathview_dropdown"),
                                     plotOutput("pathview_plot_in_ui"))
                          )
                 ),
                 # Session-info-tab ----
                 tabPanel("Session info",
                          verbatimTextOutput("sessioninfo")
                 ),
                 tabPanel("Help",
                          includeMarkdown(SigBio::app_help())
                 ),
                 tabPanel("About",
                          icon = icon("info-circle") ,
                          includeMarkdown("")
                 )
) # UI ends ----

# Server starts ----
server <- function(input, output) {
  
  # For submit of text area input
  observeEvent(input$submit, {
    
    # for progress bar
    withProgress(message = 'Steps:', value = 0, {
      
      incProgress(1/7, detail = paste("Getting Org Database...")) ##### Progress step 1
      
      # based on user input
      selected_species <- as.character(input$org)
      sigbio_message(paste("Selected org is - ", selected_species))
      selected_species_orgdb <- AnnotationHub::query(orgdb, selected_species)
      sigbio_message("Selected org AnnotationHub ID - ", selected_species_orgdb$ah_id[1])
      org_pkg <- ah[[selected_species_orgdb$ah_id[1]]]
      kegg_org_name <- input$kegg_org_code
      gtf_type <- input$id_type # ensembl or refseq
      
    output$warning <- renderUI({
      helpText("Note: It may take time for number of genes.")
    })
    
    # take gene list from text area and decode into a vector
    # if foldchange(fc) provided with coma(,) decode that in the if condition
    gene_list <- input$text_area_list
    gene_list_split <- unlist(strsplit(gene_list, "\n"))
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
    
    incProgress(2/7, detail = paste("Getting Org Database...")) ##### Progress step 2
    # Conver genelist to ENTREZIDs
    sigbio_message("Converting input gene list to entrez ids...")
    tryCatch(
      expr = {
        entrez_ids= AnnotationDbi::mapIds(org_pkg, as.character(gene_list_uprcase), 'ENTREZID', gtf_type)
        mapped_ids <- mapIds_all(genelist = as.character(gene_list_uprcase),
                                org_pkg = org_pkg,
                                gtf_type = gtf_type)
      },
      error = function(e){ 
        sigbio_message("The gene-id type and input list are not matching.")
        stop()
      },
      warning = function(w){
        sigbio_message("The gene-id type and input list are not matching.")
        stop()
      }
    )
    
    print("After Gene List converted into EntrezIDs (head): ")
    print(head(entrez_ids))
    
    # If FoldChnage provided 
    # Create a geneList with genes and log2FC for few plots
    if (all(grepl(",", gene_list_split)))
    {
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
    }
    
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
    
    # all maped ids
    output$mapped_ids_table <- DT::renderDataTable({
      as.data.frame(mapped_ids)
    })
    
    
    # Gene Ontology ----
    gene_ontology <- function(go_type = "BP"){
      sigbio_message(paste0("Doing enrichGO for: ", go_type))
      go_obj <- clusterProfiler::enrichGO(entrez_ids, OrgDb = org_pkg,
                                      keyType = "ENTREZID",ont = go_type, 
                                      pvalueCutoff=input$pval_cutoff, qvalueCutoff=input$qval_cutoff)
      sigbio_message("Converting entrezids to readable gene ids (gene symbles) ")
      go_obj_2 <- clusterProfiler::setReadable(go_obj, OrgDb = org_pkg, keyType = "ENTREZID")
      return(go_obj_2)
    }
    incProgress(3/7, detail = paste("Doing Gene Ontology for: BP...")) ##### Progress step 3
    go_bp <- gene_ontology(go_type = "BP")
    incProgress(4/7, detail = paste("Doing Gene Ontology for: CC...")) ##### Progress step 4
    go_cc <- gene_ontology(go_type = "CC")
    incProgress(5/7, detail = paste("Doing Gene Ontology for: MF...")) ##### Progress step 5
    go_mf <- gene_ontology(go_type = "MF")
    
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
      suppressMessages(library(dplyr))
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
    incProgress(6/7, detail = paste("Doing KEGG...")) ##### Progress step 6
    sigbio_message(paste0("Doing enrichKEGG... "))
    kegg <- clusterProfiler::enrichKEGG(entrez_ids, 
                       organism = kegg_org_name, 
                       pvalueCutoff=input$pval_cutoff, 
                       pAdjustMethod="BH", 
                       qvalueCutoff=input$qval_cutoff)
    kegg_2 <- clusterProfiler::setReadable(kegg, OrgDb = org_pkg, keyType = "ENTREZID")
    # kegg-table 
    output$table_kegg <- DT::renderDataTable({
      kegg_2@result
    })
    
    if (all(grepl(",", gene_list_split))){
      output$pathview_dropdown <- renderUI({
        # Copy the line below to make a select box
        selectInput("path_id", label = "Select from enriched pathway",
                    choices = kegg_2@result$ID)
      })
      
      # data preparation for next step pathview plot
      gene_data <- entrez_ids_with_fc$gene_with_fc_vector %>% as.data.frame()
      rownames(gene_data) <- entrez_ids_with_fc$entrez_ids
      
      observe({
        suppressMessages(library(pathview))
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
    if (all(grepl(",", gene_list_split))){
      # cnetplot (Gene Concept Network)
      output$cnet_plot_kegg <- renderPlot({
        enrichplot::cnetplot(kegg_2, foldChange=entrez_ids_with_fc_vector, 
                             circular = TRUE, colorEdge = TRUE)
      })
      output$pathway_gse_plot <- renderPlot({
        # gse-pathway
        pathway_gse(id_with_fc_list = entrez_ids_with_fc_vector, 
                    organism = kegg_org_name,
                    pval = input$pval_cutoff)
      })
    }else{
      output$cnet_plot_kegg <- renderPlot({
        message_plot()
      })
      output$pathway_gse_plot <- renderPlot({
        message_plot()
      })
    }
    
    # download all the tables
    output$download_tables <- downloadHandler(
      filename = function(){
        paste0("SigBio_tables.zip")
      },
      content = function(file){
        #go to a temp dir to avoid permission issues
        owd <- setwd(tempdir())
        on.exit(setwd(owd))
        
        fs <- c("go_bp.tsv", "go_cc.tsv", "go_mf.tsv", "kegg.tsv", "MappedIDs.tsv")
        write.table(go_bp@result, file = "go_bp.tsv", sep = "\t", row.names = FALSE)
        write.table(go_cc@result, file = "go_cc.tsv", sep = "\t", row.names = FALSE)
        write.table(go_mf@result, file = "go_mf.tsv", sep = "\t", row.names = FALSE)
        write.table(kegg_2@result, file = "kegg.tsv", sep = "\t", row.names = FALSE)
        write.table(mapped_ids, file = "MappedIDs.tsv", sep = "\t", row.names = FALSE)
        
        zip(zipfile=file, files=fs)
      },
      contentType = "application/zip"
    )
    
    sigbio_message("Finished. Check your browser for results.")
    incProgress(7/7, detail = paste("Finished.")) ##### Progress step 7
    
    output$sessioninfo <- renderPrint({
      sessionInfo()
    })
    
    }) # withProgress ends here
  }) # textbox area submit button observeEvent() end.
  
  # For submit of file upload
  # observeEvent(input$submit_2, {
  #   
  #   validate(
  #     need(input$file1 != "", "Please upload a file")
  #   )
  #   
  #   gene_sortlist <- input$file1
  #   gene_ids <- read.csv(gene_sortlist$datapath, header = FALSE)
  #   gene_ids_uprcase <- toupper(gene_ids$V1)
  #   
  # })
}

# Run the application 
shinyApp(ui = ui, server = server)
