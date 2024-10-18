<!-- badges: start -->
  [![R-CMD-check](https://github.com/HectorRDB/condiments/workflows/R-CMD-check/badge.svg?branch=master)](https://github.com/HectorRDB/condiments/actions)
  [![Codecov test coverage](https://codecov.io/gh/HectorRDB/condiments/branch/master/graph/badge.svg)](https://codecov.io/gh/HectorRDB/condiments?branch=master)
  [![Generic badge](https://img.shields.io/static/v1?label=DOI&message=10.1101/2021.03.09.433671&color=brightgreen)](https://doi.org/10.1101/2021.03.09.433671)
  [![DOI](https://zenodo.org/badge/294842725.svg)](https://zenodo.org/doi/10.5281/zenodo.10359878)

<!-- badges: end -->

<img src='man/figures/logo.png' align="right" height="138.5"/>

# R package: condiments 

## Installation

You can install the `condiments` from [bioconductor](https://bioconductor.org/packages/release/bioc/html/condiments.html) using

```r
if(!requireNamespace("BiocManager", quietly = TRUE)) {
 install.packages("BiocManager") 
}
BiocManager::install("condiments")
```

To install the development version in `R`, run:

```r
if(!requireNamespace("devtools", quietly = TRUE)) {
 install.packages("devtools") 
}
devtools::install_github("HectorRDB/condiments")
```

The installation should only take a few seconds.
The dependencies of the package are listed in the DESCRIPTION file of the package.

## Issues and bug reports

Please use https://github.com/HectorRDB/condiments/issues to submit issues, bug reports, and comments.

## Usage 

Start with the vignette [online](https://hectorrdb.github.io/condiments/articles/condiments.html) or explore on of our case studies in the paper [here](https://hectorrdb.github.io/condimentsPaper).
