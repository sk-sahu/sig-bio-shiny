gene_string <- "ENSG00000196611,0.7
ENSG00000093009,1.2
ENSG00000109255,-0.3
ENSG00000134690,0.2
ENSG00000065328,1.7
ENSG00000117399,-0.5"

test_that("Input gene list is working cool", {
  expect_length(app_parse_textarea(gene_string), 2)
})
