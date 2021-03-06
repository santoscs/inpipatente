% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/buscarpatente.R
\name{buscar_patente_cnpj}
\alias{buscar_patente_cnpj}
\title{Busca patentes por CNPJ no site do INPI}
\usage{
buscar_patente_cnpj(cnpj)
}
\arguments{
\item{cnpj}{numero do CNPJ, com ou sem os caracteres especiais.}
}
\value{
Se o CNPJ nao possui patente retorna 0, se possui
retorna uma matriz com o numero, data do deposito e 
nome da patente.
}
\description{
Realiza uma busca de patentes por CNPJ na INPI.
}
