# # test fucntion on few human ensembl genes
# suppressMessages(library(AnnotationHub))
# suppressMessages(library(AnnotationDbi))
# ah = AnnotationHub()
# org_pkg <- ah[["AH70572"]]
# genelist <- as.character(c("ENSG00000012048", "ENSG00000214049", "ENSG00000204682"))
# 
# test_that('if able to map all the ids', {
#   expect_true(is.data.frame(mapIds_all(genelist = as.character(genelist), org_pkg = org_pkg, gtf_type = "ENSEMBL")))
# })
# 
# 
