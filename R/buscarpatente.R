


check_cnpj <- function(cnpj) {
  cnpj <- gsub('[^0-9]', '', cnpj)
  if (nchar(cnpj) != 14) stop('CNPJ Invalido.')
  cnpj
}


#' Busca patentes por CNPJ no site do INPI
#'
#' Realiza uma busca de patentes por CNPJ na INPI.
#'
#' @param cnpj numero do CNPJ, com ou sem os caracteres especiais.
#'
#' @return Se o CNPJ nao possui patente retorna 0, se possui
#' retorna uma matriz com o numero, data do deposito e 
#' nome da patente.
#' 
#' @import RSelenium rvest xml2
#'
#' @export
#' 
buscar_patente_cnpj <- function(cnpj) {
  cnpj <- check_cnpj(cnpj)
  remDr <- remoteDriver(remoteServerAddr = "localhost" 
                        , port = 4445L
                        , browserName = "firefox")
  
  remDr$open(silent = TRUE)
  
  
  remDr$navigate("https://gru.inpi.gov.br/pePI/jsp/marcas/Pesquisa_num_processo.jsp")
  webElem <- remDr$findElement(using = 'class', value = "marcador")
  webElem$clickElement()
  
  Sys.sleep(7)
  remDr$navigate("https://gru.inpi.gov.br/pePI/jsp/patentes/PatenteSearchBasico.jsp")
  webElems <- remDr$findElements("css", "[href]")
  resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
  webElem <- webElems[[which(resHeaders == "Pesquisa Avançada")]]
  webElem$clickElement()
  
  Sys.sleep(6)
  webElems <- remDr$findElements("class", "accordion")
  resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
  webElem <- webElems[[which(resHeaders == "  Depositante/Titular/Inventor")]]
  webElem$clickElement()
  
  #remDr$getCurrentUrl()
  
  Sys.sleep(8)
  webElem <- remDr$findElement(using = "css", "[name = 'CpfCnpjDepositante']")
  webElem$sendKeysToElement(list(cnpj, "\uE007"))
  
  
  
  Sys.sleep(9)
  if(!remDr$getCurrentUrl()[[1]]=="https://gru.inpi.gov.br/pePI/servlet/PatenteServletController"){
    stop("no load page results")
  }
  
  test.html <- read_html(remDr$getPageSource()[[1]])
  
  
  results<-test.html %>%
    html_nodes("[class = 'normal']") %>%
    html_text()
  
  results <- gsub("\\n", "", results)
  results <- gsub("\\t", "", results)
  results <- gsub(" ", "", results)
  
  if(sum(grepl("Pedido", results))==0){
    results <- 0
  }else{
    if(sum(grepl("Página de Resultados", results))==0){
      
      results[6] <- strsplit(results[6], "[.]")[[1]][2]
      npag <- gsub("Mostrandopágina1de", "", results[6])
      npag <- as.numeric(npag)
      results <- results[-c(1:10)]
      n <- length(results)
      fim <- grep("PáginasdeResultados", results)
      results <- results[-c(fim:n)]
      results <- matrix(results, ncol = 3, byrow = TRUE)
      
      if(npag==1){
        next()
      }else{
        for(j in 2:npag){
          webElems <- remDr$findElements("css", "[href]")
          resHeaders <- unlist(lapply(webElems, function(x){x$getElementText()}))
          webElem <- webElems[[which(resHeaders == as.character(j))]]
          webElem$clickElement()
          Sys.sleep(6)
          test.html <- read_html(remDr$getPageSource()[[1]])
          
          aux<-test.html %>%
            html_nodes("[class = 'normal']") %>%
            html_text()
          
          aux <- gsub("\\n", "", aux)
          aux <- gsub("\\t", "", aux)
          aux <- gsub(" ", "", aux)
          aux <- aux[-c(1:10)]
          
          n <- length(aux)
          fim <- grep("PáginasdeResultados", aux)
          aux <- aux[-c(fim:n)]
          aux <- matrix(aux, ncol = 3, byrow = TRUE)
          results<- rbind(results, aux)
        }
      }
    }else{
      results <- results[-c(1:10)]
      results <- results[-length(results)]
      results <- matrix(results, ncol = 3, byrow = TRUE)
    }
  }
  
  remDr$close()
  return(results)
}




