#' Principal Component Analysis for annmatrix
#'
#' Perform principal component analysis on an annmatrix object.
#'
#' Performs PCA on annmatrix and preserves row and column annotations in scores and loadings.
#'
#' @param x annmatrix object.
#' @param retx logical indicator whether the rotated variables should be returned (defaults to TRUE).
#' @param center logical value indicating whether variables should be centered (defaults to TRUE).
#' @param scale. logical value indicating whether variables should be scaled (defaults to FALSE).
#' @param tol tolerance value indicating magnitude below which components will be omitted.
#' @param rank. number specifying the maximal rank (max number of principal components to be used).
#' @param ... arguments passed to or from other methods.
#'
#' @return prcom object with rotation and x matrices turned into annmatrix
#'
#' @examples
#' # construct the annmatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' X <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' prcomp(t(X))
#'
#' @author Karolis Koncevičius
#' @export
prcomp.annmatrix <- function(x, retx = TRUE, center = TRUE, scale. = FALSE, tol = NULL, rank. = NULL, ...) {
  res  <- NextMethod(as.matrix(x), retx = retx, center = center, scale. = scale., tol = tol, rank. = rank., ...)
  info <- data.frame(pc  = colnames(res$rotation),
                     sd  = res$sdev,
                     var = res$sdev^2,
                     var_explained = res$sdev^2 / sum(res$sdev^2),
                     row.names = colnames(res$rotation)
                     )
  res$rotation <- annmatrix(res$rotation, rann = attr(x, ".annmatrix.cann"), cann = info)
  if(retx) res$x <- annmatrix(res$x, rann = attr(x, ".annmatrix.rann"), cann = info)
  res
}
