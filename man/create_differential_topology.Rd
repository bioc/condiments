% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/toy.R
\name{create_differential_topology}
\alias{create_differential_topology}
\title{Create Example function}
\usage{
create_differential_topology(
  n_cells = 200,
  noise = 0.15,
  shift = 10,
  unbalance_level = 0.9,
  speed = 1
)
}
\arguments{
\item{n_cells}{The number of cells in the dataset.}

\item{noise}{Amount of noise. Between 0 and 1.}

\item{shift}{How much should the top lineage shift in condition B.}

\item{unbalance_level}{How much should the bottom lineage be unbalanced toward
condition A.}

\item{speed}{How fast the cells from condition B should differentiate}
}
\value{
A list with two components
 \itemize{
  \item \code{sd}: An \code{n_cells} by \code{4} dataframe that contains the
  reduced dimensions coordinates, lineage assignment (1 or 2) and condition
  assignment (A or B) for each cell.
  \item \code{mst}: a data.frame that contains the skeleton of the trajectories
}
}
\description{
This creates a simulated reduced dimension dataset
}
\examples{
sd <- create_differential_topology()
}
