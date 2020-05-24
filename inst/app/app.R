# Sig-Bio-Shiny Application
# Home Page - http://sk-sahu.github.io/sig-bio-shiny/
# Source Code - https://github.com/sk-sahu/sig-bio-shiny
# Developed and maintain by Sangram Keshari Sahu (https://sksahu.net)

sigbio.version='0.3.0'

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
    sidebarMenu(id = "tabs",
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
                )
              ),
             helpText("After submit it may take 1-2 minutes. Check Progress bar in right
                                                  side cornor."),
             
             actionButton("submit", label =  "Submit",
                          icon = icon("angle-double-right")),
             ###### Validate UI #########
             app_input_validate_ui("input_validate")
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
  )
                 
) # UI ends ----

# Server starts ----
server <- function(input, output) {
  
  # a global reactive list which will hold all the input parsed through input validate module
  app_input <- reactiveValues(
    gene_list_uprcase = NULL,
    gene_with_fc_df = NULL,
    entrez_ids = NULL,
    entrez_ids_with_fc = NULL,
    entrez_ids_with_fc_vector = NULL,
    org_pkg = NULL,
    kegg_org_name = NULL,
    gtf_type = NULL
  )
  
  # For submit of text area input
  observeEvent(input$submit, {
    
    # for progress bar
    withProgress(message = 'Steps:', value = 0, {
      
      incProgress(1/7, detail = paste("Getting Org Database...")) ##### Progress step 1
      
      validated_app_input <- callModule(app_input_validate_server, "input_validate",
                             input_org = input$org,
                             input_orgdb = orgdb,
                             input_ah = ah,
                             input_kegg_org_code = input$kegg_org_code,
                             input_id_type = input$id_type,
                             input_text_area_list = input$text_area_list)
      
      
      app_input$gene_list_uprcase = validated_app_input$gene_list_uprcase
      app_input$gene_with_fc_df = validated_app_input$gene_with_fc_df
      app_input$entrez_ids = validated_app_input$entrez_ids
      app_input$entrez_ids_with_fc = validated_app_input$entrez_ids_with_fc
      app_input$entrez_ids_with_fc_vector = validated_app_input$entrez_ids_with_fc_vector
      app_input$org_pkg = validated_app_input$org_pkg
      app_input$kegg_org_name = validated_app_input$kegg_org_name
      app_input$gtf_type = validated_app_input$gtf_type
      
      
    }) # withProgress ends here
  }) # textbox area submit button observeEvent() end.
  
  # https://stackoverflow.com/questions/53049659/loading-shiny-module-only-when-menu-items-is-clicked
  observeEvent(input$tabs, {
    
    # all maped ids
    if(input$tabs=="mapped-ids"){
        callModule(mapids_server, "mapids", 
                  gene_list_uprcase = app_input$gene_list_uprcase,
                  org_pkg = app_input$org_pkg,
                  gtf_type = app_input$gtf_type)
    }
    
    # gene ontology
    if(input$tabs=="gene-ontology"){
      callModule(enrichGO_server, "enrichgo",
                gene_list = app_input$gene_list_uprcase,
                gene_list_with_fc = app_input$gene_list_with_fc,
                entrez_ids_with_fc_vector = app_input$entrez_ids_with_fc_vector,
                entrez_ids = app_input$entrez_ids,
                org_pkg = app_input$org_pkg,
                pval_cutoff = input$pval_cutoff,
                qval_cutoff = input$qval_cutoff)
      }
      
    # KEGG ----
    if(input$tabs=="kegg"){
      incProgress(6/7, detail = paste("Doing KEGG...")) ##### Progress step 6
      sigbio_message(paste0("Doing enrichKEGG... "))
      callModule(enrichKEGG_server, "enrichkegg",
                gene_list_with_fc = app_input$gene_list_with_fc,
                entrez_ids_with_fc_vector = app_input$entrez_ids_with_fc_vector,
                entrez_ids_with_fc = app_input$entrez_ids_with_fc,
                entrez_ids = app_input$entrez_ids,
                org_pkg = app_input$org_pkg,
                kegg_org_name = app_input$kegg_org_name,
                pval_cutoff = input$pval_cutoff,
                qval_cutoff = input$qval_cutoff)
    }
  }, ignoreNULL = TRUE, ignoreInit = TRUE)

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
    
  
} # serer ends ----

# Run the application 
shinyApp(ui = ui, server = server)
