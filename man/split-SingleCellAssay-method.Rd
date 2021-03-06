% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SingleCellAssay-methods.R
\docType{methods}
\name{split,SingleCellAssay-method}
\alias{split,SingleCellAssay,ANY-method}
\alias{split,SingleCellAssay-method}
\title{Split into SCASet}
\usage{
\S4method{split}{SingleCellAssay}(x, f, drop = FALSE, ...)
}
\arguments{
\item{x}{SingleCellAssay}

\item{f}{length-1 character or factor of length nrow(x)}
}
\value{
SCASet
}
\description{
Splits a \code{SingleCellAssay} into a \code{SCASet} by a factor (or something coercible into a factor) or a character giving a column of the melted SingleCellAssay
}
\examples{
data(vbetaFA)
split(vbetaFA, 'ncells')
fa <- as.factor(cData(vbetaFA)$ncells)
split(vbetaFA, fa)
}

