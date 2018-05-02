#package creation inpipatente

##inicia o pacote
#install.packages("devtools")
devtools::setup(rstudio = FALSE)

##preencher o DESCRIPTION

## cria pasta para dados brutos
devtools::use_data_raw()

# Ignora o que tem em data-raw
devtools::use_build_ignore("data-raw")

# Ignora Rproj do Rstudio
devtools::use_build_ignore("inpipatente.Rproj")


#Escrevas as funcoes e salve em R

# documenta as funcoes
devtools::document()

# coloca as dependencias no pacote
devtools::use_package("RSelenium")
devtools::use_package("rvest")
devtools::use_package("xml2")

# testa o pacote, provavelmente recebera um erro de 
# dependencia
devtools::check()

