% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/SingleCellAssay-methods.R
\name{melt.SingleCellAssay}
\alias{melt.SingleCellAssay}
\title{Melt a rectangular array}
\usage{
\method{melt}{SingleCellAssay}(data, ...)
}
\arguments{
\item{data}{A rectangular array, with attributes attached to its rows and
columns}

\item{...}{ignored}
}
\value{
A \code{data.frame} typically, with the cartesian product of the
row and column attributes and the values from the rectangular array
}
\description{
Return a 'molten' (flat) representation of a rectangular array
}

