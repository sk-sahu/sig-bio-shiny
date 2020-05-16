# Sig-Bio-Shiny Application
# Home Page - http://sk-sahu.github.io/sig-bio-shiny/
# Source Code - https://github.com/sk-sahu/sig-bio-shiny
# Developed and maintain by Sangram Keshari Sahu (https://sksahu.net)

sigbio.version='0.2.3'

message("Running Sig-Bio-Shiny v", sigbio.version, " | ",date())
message("Checking if SigBio v", sigbio.version, " Package is installed...")

if("SigBio" %in% rownames(installed.packages()) && 
   packageVersion("SigBio") != sigbio.version){
  options(repos = c(CRAN = "http://cran.rstudio.com"))
  if (!require(remotes)) { install.packages("remotes") }
  remotes::install_github("sk-sahu/sig-bio-shiny", 
                          ref = paste0("v", sigbio.version))
}

suppressMessages(library(SigBio))

sigbio_message("Starting the application...")
# Load organisms
org <- SigBio::app_getOrg()
ah <- org$ah_obj
orgdb <- org$ah_orgdb
kegg_list <- org$kegg_org_list

example_genelist <- "
ENSG00000196611,0.7
ENSG00000093009,1.2
ENSG00000109255,-0.3
ENSG00000134690,0.2
ENSG00000065328,1.7
ENSG00000117399,-0.5"

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  dashboardHeader(title = paste0("Sig-Bio v",sigbio.version)),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Input", tabName = "input", icon = icon("dashboard")),
      menuItem("Mapped Ids", tabName = "mapped-ids", icon = icon("dashboard")),
      menuItem("Gene Ontology", tabName = "gene-ontology", icon = icon("dashboard")),
      menuItem("KEGG", tabName = "kegg", icon = icon("dashboard")),
      menuItem("session-info", tabName = "session-info", icon = icon("dashboard")),
      menuItem("Help", tabName = "help", icon = icon("dashboard")),
      menuItem("About", tabName = "about", icon = icon("dashboard"))
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "input",
              fluidRow(
                box(title = "Gene Input", 
                  textAreaInput("text_area_list", 
                                label = "[Gene] or [Gene,Foldchnage] list:", 
                                height = "150px", width = "230px",
                                value = example_genelist),
                  selectInput("id_type", label = "Input gene-id Type:", selected = "ENSEMBL",
                              choices=c("ENSEMBL", "REFSEQ", "ENTREZID"))
                ),
                box(title = "Organism Input",
                  selectInput("org", label = "Organism:", selected = "Homo sapiens",
                              choices=orgdb$species),
                  selectInput("kegg_org_code", 
                              label = "KEGG Organism Short Name:",
                              selected = "hsa",
                              choices=kegg_list$org_code),
                              helpText("Get your KEGG Organism short name from here - https://www.genome.jp/kegg/catalog/org_list.html")
                ),
                box(title = "Significant Values Input",
                  numericInput("pval_cutoff", label = "pvalue-CutOff", 
                               value = 1, min=0.001, max=1),
                  numericInput("qval_cutoff", label = "qvalue-CutOff", 
                               value = 1, min=0.001, max=1)
                ),
              ),
             helpText("After submit it may take 1-2 minutes. Check Progress bar in right
                                                  side cornor."),
             
             actionButton("submit", label =  "Submit",
                          icon = icon("angle-double-right")),
             textOutput("gene_number_info"),
             DT::dataTableOutput(outputId = "gene_number_info_table")
             ),
      
      # mapped ids
    tabItem("mapped-ids",
               mapids_ui("mapids")
      ),
      
      # gene ontology
    tabItem("gene-ontology",
               enrichGO_ui("enrichgo")
      ),
      
      # KEGG-Tab ----
    tabItem("kegg",
               enrichKEGG_ui("enrichkegg")
      ),
      # Session-info-tab ----
    tabItem("session-info",
               verbatimTextOutput("sessioninfo")
      ),
    tabItem("help",
               includeHTML("")
      ),
    tabItem("about",
               icon = icon("info-circle") ,
               includeHTML("")
      )
  )
  ),
                 
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
      
    # get user input and parse
    text_area_input <- SigBio::app_getInput(input$text_area_list)
    gene_list_uprcase <- text_area_input$gene_list
    gene_with_fc_df <- text_area_input$gene_list_with_fc
    
    incProgress(2/7, detail = paste("Getting Org Database...")) ##### Progress step 2
    # Conver genelist to ENTREZIDs
    sigbio_message("Converting input gene list to entrez ids...")
    tryCatch(
      expr = {
        entrez_ids= AnnotationDbi::mapIds(org_pkg, as.character(gene_list_uprcase), 'ENTREZID', gtf_type)
        mapped_ids <- do_selectIds(genelist = as.character(gene_list_uprcase),
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
    if (!is.null(text_area_input$gene_list_with_fc))
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
    callModule(mapids_server,"mapids", mapped_ids)
    
    # gene ontology
    callModule(enrichGO_server,"enrichgo", 
               gene_list = text_area_input$gene_list,
               gene_list_with_fc = text_area_input$gene_list_with_fc,
               entrez_ids_with_fc_vector = entrez_ids_with_fc_vector,
               entrez_ids = entrez_ids, 
               org_pkg = org_pkg,
               pval_cutoff = input$pval_cutoff,
               qval_cutoff = input$qval_cutoff)
    
    # KEGG ----
    incProgress(6/7, detail = paste("Doing KEGG...")) ##### Progress step 6
    sigbio_message(paste0("Doing enrichKEGG... "))
    callModule(enrichKEGG_server,"enrichkegg", 
               gene_list_with_fc = text_area_input$gene_list_with_fc,
               entrez_ids_with_fc_vector = entrez_ids_with_fc_vector,
               entrez_ids_with_fc = entrez_ids_with_fc,
               entrez_ids = entrez_ids,
               org_pkg = org_pkg,
               kegg_org_name = kegg_org_name,
               pval_cutoff = input$pval_cutoff,
               qval_cutoff = input$qval_cutoff)

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
