# the arguments are result data frames returned by clusterProfiler::enrichGO objects
# it retuns a ploting object

library(dplyr)
library(ggplot2)
library(forcats)

wego_plot <- function(BP=go_table, CC=go_table, MF=go_table){
  
  # add domain information to an extra column to each dataframe
  BP_2 <- cbind(BP, c(rep("Biological Process", nrow(BP))))
  colnames(BP_2)[10] <- "Domain"
  CC_2 <- cbind(CC, c(rep("Cellular Components", nrow(CC))))
  colnames(CC_2)[10] <- "Domain"
  MF_2 <- cbind(MF, c(rep("Molecular Functions", nrow(MF))))
  colnames(MF_2)[10] <- "Domain"
  
  # merge all GO data in a single obejct ----
  all_go_data <- rbind(BP_2, CC_2, MF_2)
  
  # make wego style output ----
  wego_style_go <- all_go_data %>% 
    select(ID, Domain, Count, GeneRatio, Description)
  # get total number of genes 
  total <-as.numeric(gsub("[1-9]/", "", wego_style_go[1,4]))
  wego_style_go <- cbind(wego_style_go[-4], (wego_style_go$Count/total)*100)
  colnames(wego_style_go)[3] <- "Number of genes"
  colnames(wego_style_go)[5] <- "Percentage of genes"
  
  # Reference blog: https://sarahpenir.github.io/r/WEGO/
  
  # Preparing the table for plotting ----
  wego_style_go_2 <- wego_style_go %>%
    ## Group the entries by "Domain"
    group_by(Domain) %>%
    ## Take the top 5 entries per "Domain" according to "Percentage of genes"
    top_n(5, `Percentage of genes`) %>% 
    ## Ungroup the entries
    ungroup() %>% 
    ## Arrange the entries by "Domain", then by "Percentage of genes"
    arrange(Domain, `Percentage of genes`) %>% 
    ## Take note of the arrangement by creating a "Position" column
    mutate(Position = n():1)
  
  wego_style_go_2 <- wego_style_go_2[, c(1,2,3,5,4,6)]
  
  # making wego alike plot ----
  
  ## Calculate the normalizer to make "Number of genes" proportional to 
  ## "Percentage of genes" for the plotting of the second y-axis
  normalizer <- max(wego_style_go_2$`Number of genes`)/max(wego_style_go_2$`Percentage of genes`)
  
  ## Plot "Description" in the x-axis following the order stated in the "Position" column
  ## vs "Percentage of genes" in the first y-axis
  wego_alike_plot <- ggplot(data = wego_style_go_2, aes(x = fct_reorder(Description, desc(Position)), y = `Percentage of genes`, fill = Domain)) +
    ## Plot "Description" in the x-axis following the order stated in the "Position" column
    ## vs normalized "Number of genes" in the second y-axis
    geom_col(data = wego_style_go_2, aes(x = fct_reorder(Description, desc(Position)), y = `Number of genes`/normalizer)) +
    ## Add a second y-axis based on the transformation of "Percentage of genes" to "Number of genes".
    ## Notice that the transformation undoes the normalization for the earlier geom_col.
    scale_y_continuous(sec.axis = sec_axis(trans = ~.*normalizer, name = "Number of genes")) +
    ## Modify the aesthetic of the theme
    theme(axis.text.x = element_text(angle = 70, hjust = 1), axis.title.y = element_text(size = 8),
          legend.text = element_text(size = 7), legend.title = element_text(size = 8),
          legend.key.size =  unit(0.2, "in"), plot.title = element_text(size = 11, hjust = 0.5)) +
    ## Add a title to the plot
    labs(x = NULL, title = "Gene Ontology (GO) Annotation") + 
    # theme settings
    theme(text = element_text(size=20),
          axis.text = element_text(size = 15),
          axis.text.x = element_text(angle = 60), 
          panel.background = element_rect(fill = "white", colour = "grey50"))
  return(wego_alike_plot)
}
