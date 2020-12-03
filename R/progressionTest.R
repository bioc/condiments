.perm_stat <- function(pst_l, w_l, conditions) {
  d_l <- stats::weighted.mean(pst_l[conditions == unique(conditions)[1]],
                              w_l[conditions == unique(conditions)[1]]) -
         stats::weighted.mean(pst_l[conditions == unique(conditions)[2]],
                              w_l[conditions == unique(conditions)[2]])
  return(d_l)
}

.progressionTest <- function(sds, conditions, global = TRUE, lineages = FALSE,
                             method = "KS",  thresh = 0.05, rep = 1e4, ...) {
  # Get variables
  pst <- slingshot::slingPseudotime(sds, na = FALSE)
  w <- slingshot::slingCurveWeights(sds, as.probs = TRUE)
  colnames(pst) <- colnames(w) <-
    paste0("lineage", seq_len(ncol(pst)))
  n_conditions <- dplyr::n_distinct(conditions)
  # Get lineage levels p-values
  lineages_test <- lapply(colnames(pst), function(l){
    w_l <- w[, l]
    pst_l <- pst[, l]
    if (method == "KS") {
      test_l <- Ecume::ks_test(x = pst_l[conditions == unique(conditions)[1]],
                               w_x = w_l[conditions == unique(conditions)[1]],
                               y = pst_l[conditions == unique(conditions)[2]],
                               w_y = w_l[conditions == unique(conditions)[2]],
                               thresh = thresh)
      return(c("statistic" = test_l$statistic, "p.value" = test_l$p.value))
    }
    if (method == "Permutation") {
      d_l <- .perm_stat(pst_l, w_l, conditions)
      d_il <- replicate(rep, {
        conditions_i <- sample(conditions)
        return(.perm_stat(pst_l, w_l, conditions_i))
      })
      return(c("statistic" = d_l,
               "p.value" = max(mean(abs(d_l) <= abs(d_il)), 1 / rep)))
    }
    if (method == "Classifier") {
      xs <- lapply(unique(conditions), function(cond) {
        return(as.matrix(pst_l[conditions == cond]))
      })
      test_l <- Ecume::classifier_test(x = xs, thresh = thresh, ...)
      return(c("statistic" = test_l$statistic, "p.value" = test_l$p.value))
    }
    if(method == "mmd") {
      n <- max(table(conditions))
      frac <- 10^5 / (n * (n - 1))
      test_l <- Ecume::mmd_test(
        x = as.matrix(pst_l[conditions == unique(conditions)[1]]),
        y = as.matrix(pst_l[conditions == unique(conditions)[2]]),
        frac = frac, ...)
      return(c("statistic" = test_l$statistic, "p.value" = test_l$p.value))
    }
  }) %>%
    dplyr::bind_rows(.id = "lineage") %>%
    dplyr::mutate(lineage = as.character(lineage)) %>%
    dplyr::select(lineage, statistic, p.value)
  if (method == "Classifier") {
    xs <- lapply(unique(conditions), function(cond) {
      as.matrix(pst[conditions == cond, ])
    })
    glob_test <- Ecume::classifier_test(xs, thresh = thresh, ...)
  }
  if (method == "mmd") {
    n <- max(table(conditions))
    frac <- 10^5 / (n * (n - 1))
    glob_test <- Ecume::mmd_test(
      x = as.matrix(pst[conditions == unique(conditions)[1], ]),
      y = as.matrix(pst[conditions == unique(conditions)[2], ]),
      frac = frac, ...)
  }
  if (method %in% c("KS", "Permutation")) {
    glob_test <- Ecume::stouffer_zscore(pvals = lineages_test$p.value / 2,
                                            weights = colSums(w))
  }

  glob_test <- data.frame("lineage" = "All",
                          "statistic" = glob_test$statistic,
                          "p.value" = glob_test$p.value)
  if (global == TRUE & lineages == FALSE) return(glob_test)
  if (global == FALSE & lineages == TRUE) return(lineages_test)
  if (global == TRUE & lineages == TRUE) {
    return(dplyr::bind_rows(glob_test, lineages_test))
  }
}


#' Differential Progression Test
#'
#' @description Test whether or not the pseudotime distribution are identical
#' within lineages between conditions
#'
#' @param sds The final object after running slingshot. Can be either a
#' \code{\link{SlingshotDataSet}} or a \code{\link{SingleCellExperiment}} object.
#' @param conditions Either the vector of conditions, or a character indicating
#' which column of the metadata contains this vector.
#' @param global If TRUE, test for all lineages simultaneously.
#' @param lineages If TRUE, test for all lineages independently.
#' @param method One of "KS" for the weighted Kolmogorov-Smirnov, "Classifier"
#' for the classifier method or "Permutation" for a permutation. See details.
#' Default to KS if there is two conditions and to "Classifier" otherwise.
#' @param thresh The threshold for the KS test or Classifier test.
#' Ignored if \code{method = "Permutation"}. Default to .05.
#' @param rep Number of permutations to run. Ignored if \code{method = "KS"}.
#' Default to \code{1e4}.
#' @param ... Other arguments passed to \link[Ecume]{classifier_test}.
#' @importFrom slingshot slingshot SlingshotDataSet slingPseudotime slingCurveWeights
#' @importFrom stats weighted.mean
#' @importFrom dplyr n_distinct bind_rows mutate select
#' @details
#' For every lineage, we compare the pseudotimes of the cells from either
#' conditions, using the lineage weights as observations weights.
#' \itemize{
#'   \item If \code{method = "KS"}, this uses the updated KS test,
#'   see \code{\link{ks_test}} for details.
#'   \item If \code{method = "Classifier"}, this uses a classifier to assess if
#'   that classifier can do better than chance on the conditions
#'   \item If \code{method = "Permutation"}, the difference of weighted mean
#'   pseudotime between condition is computed, and a p-value is found by
#'   permuting the condition labels.
#'   \item If \code{method = "mmd"}, this uses the mean maximum discrepancies
#'    statistics.
#' }
#' The p-value at the global level can be computed in two ways. method is \code{"KS"} or
#'  \code{"Permutation"}, then the p-values are computed using stouffer's
#'  z-score method, with the lineages weights acting as weights. Otherwise,
#'  the test works on multivariate data and is applied on all pseudotime values.
#' @references  Stouffer, S.A.; Suchman, E.A.; DeVinney, L.C.; Star, S.A.;
#' Williams, R.M. Jr. (1949).
#' *The American Soldier, Vol.1: Adjustment during Army Life.*
#' Princeton University Press, Princeton.
#' @md
#' @return A data frame with 3 columns:
#' \itemize{
#'   \item *lineage* for individual lineages, the lineage number. For global,
#'   \code{"All"}.
#'   \item *p.value* the pvalue for the test at the global or lineage level
#'   \item *statistic* for individual lineages, either the modified KS statistic
#'   if \code{method = "KS"}, or the weighted difference of means, if
#'   \code{method = "Permutation"}. For the global test, the combined Z-score.
#' }
#' @examples
#' data('slingshotExample', package = "slingshot")
#' rd <- slingshotExample$rd
#' cl <- slingshotExample$cl
#' condition <- factor(rep(c('A','B'), length.out = nrow(rd)))
#' condition[110:139] <- 'A'
#' sds <- slingshot::slingshot(rd, cl)
#' progressionTest(sds, condition)
#' @importFrom Ecume classifier_test ks_test stouffer_zscore mmd_test
#' @export
#' @rdname progressionTest
setMethod(f = "progressionTest",
          signature = c(sds = "SlingshotDataSet"),
          definition = function(sds, conditions, global = TRUE, lineages = FALSE,
    method = ifelse(dplyr::n_distinct(conditions) == 2, "KS", "Classifier"),
    thresh = .05, rep = 1e4, ...){
            if (!method %in% c("KS", "Permutation", "Classifier", "mmd")) {
              stop("Method must be one of KS, Classifier, mmd or permutation")
            }
            if (n_distinct(conditions) > 2 && method != "Classifier") {
              warning(paste0("Changing to method classifier since more than ",
                             "two conditions are present."))
              method <- "Classifier"
            }
            if (!method %in% c("KS", "Permutation", "Classifier", "mmd")) {
              stop("Method must be one of KS, Classifier, mmd or permutation")
            }
            res <- .progressionTest(sds = sds, conditions = conditions,
                                    global = global, lineages = lineages,
                                    method = method, thresh = thresh,
                                    rep = rep, ...)
            return(res)
          }
)


#' @export
#' @rdname progressionTest
#' @importClassesFrom SingleCellExperiment SingleCellExperiment
#' @importFrom SummarizedExperiment colData
setMethod(f = "progressionTest",
          signature = c(sds = "SingleCellExperiment"),
          definition = function(sds, conditions, global = TRUE, lineages = FALSE,
    method = ifelse(dplyr::n_distinct(conditions) == 2, "KS", "Classifier"),
    thresh = .05, rep = 1e4, ...){
            if (is.null(sds@int_metadata$slingshot)) {
              stop("For now this only works downstream of slingshot")
            }
            if (length(conditions) == 1) {
              if (conditions %in% colnames(SummarizedExperiment::colData(sds))) {
                conditions <- SummarizedExperiment::colData(sds)[, conditions]
              } else {
                stop("conditions is not a column of colData(sds)")
              }
            }
            return(progressionTest(slingshot::SlingshotDataSet(sds),
                                   conditions = conditions, global = global,
                                   lineages = lineages, method = method,
                                   thresh = thresh, rep = rep, ...))
          }
)