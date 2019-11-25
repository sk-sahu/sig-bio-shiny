kegg_rest <- function(rest_url) {
  content <- tryCatch(suppressWarnings(readLines(rest_url)), error=function(e) NULL)
  if (is.null(content))
    return(content)
  
  content %<>% strsplit(., "\t") %>% do.call('rbind', .)
  res <- data.frame(id=content[,1],
                    org_code=content[,2],
                    org_name=content[,3])
  return(res)
}

kegg_link <- function(){
  url <- paste0("http://rest.kegg.jp/list/organism", collapse="")
  kegg_rest(url)
}

#kegg_list <- kegg_link()
