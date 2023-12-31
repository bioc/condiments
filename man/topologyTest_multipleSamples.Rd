% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AllGenerics.R, R/multiple_samples.R
\name{topologyTest_multipleSamples}
\alias{topologyTest_multipleSamples}
\alias{topologyTest_multipleSamples,SlingshotDataSet-method}
\alias{topologyTest_multipleSamples,SingleCellExperiment-method}
\alias{topologyTest_multipleSamples,PseudotimeOrdering-method}
\title{Differential Topology Test with multiple samples}
\usage{
topologyTest_multipleSamples(sds, ...)

\S4method{topologyTest_multipleSamples}{SlingshotDataSet}(sds, conditions, Samples, ...)

\S4method{topologyTest_multipleSamples}{SingleCellExperiment}(sds, conditions, Samples, ...)

\S4method{topologyTest_multipleSamples}{PseudotimeOrdering}(sds, conditions, Samples, ...)
}
\arguments{
\item{sds}{A slingshot object already run on the full dataset. Can be either a
\code{\link{SlingshotDataSet}} or a \code{\link{SingleCellExperiment}} object.}

\item{...}{Other arguments passed to \code{\link{topologyTest}}.}

\item{conditions}{Either the vector of conditions, or a character indicating which
column of the metadata contains this vector.}

\item{Samples}{A vector assigning each cell to a sample. Samples must be shared across all conditions.}
}
\value{
The same object has the \code{\link{topologyTest}} with one more column per sample.
}
\description{
Test whether or not slingshot should be fitted independently
for different conditions or not, per sample, with samples not being confounded by conditions.
}
\examples{
data('slingshotExample', package = "slingshot")
rd <- slingshotExample$rd
cl <- slingshotExample$cl
condition <- factor(rep(c('A','B'), length.out = nrow(rd)))
condition[110:139] <- 'A'
sds <- slingshot::slingshot(rd, cl)
samples <- sample(1:2, 140, replace = TRUE)
topologyTest_multipleSamples(sds = sds, conditions = condition,
                             Samples = samples, rep = 10)
}
