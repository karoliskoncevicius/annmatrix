#' Principal Component Analysis for annmatrix Objects
#'
#' Performs principal component analysis on annmatrix objects and preserves row and column annotations in scores and loadings.
#'
#' The resulting loadings ('rotation') and scores ('x') are turned into annmatrix objects with additional row and column annotations.
#' Row annotations are copied from the original input matrix while column annotations contain computed information about each principal component.
#' The added information contains: 1) principal component number, 2) standard deviation, 3) variance, 4) fraction of variance explained.
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
#' # construct annmatrix object
#' x <- matrix(rnorm(20*10), 20, 10)
#'
#' coldata <- data.frame(group  = rep(c("case", "control"), each = 5),
#'                       gender = sample(c("M", "F"), 10, replace = TRUE))
#'
#' rowdata <- data.frame(chr = sample(c("chr1", "chr2"), 20, replace = TRUE),
#'                       pos = runif(20, 0, 1000000))
#'
#' X <- as.annmatrix(x, rowdata, coldata)
#'
#' pca <- prcomp(t(X))
#' pca$rotation
#' pca$rotation$''
#'
#' scores <- t(pca$rotation) %*% X
#' scores@var_explained
#' scores$gender
#'
#' @author Karolis Koncevičius
#' @name pca
#' @export
prcomp.annmatrix <- function(x, retx = TRUE, center = TRUE, scale. = FALSE, tol = NULL, rank. = NULL, ...) {
  res  <- NextMethod(as.matrix(x), retx = retx, center = center, scale. = scale., tol = tol, rank. = rank., ...)
  info <- data.frame(pc  = colnames(res$rotation),
                     sd  = res$sdev,
                     var = res$sdev^2,
                     var_explained = res$sdev^2 / sum(res$sdev^2),
                     row.names = colnames(res$rotation)
                     )
  res$rotation <- as.annmatrix(res$rotation, rann = attr(x, ".annmatrix.cann"), cann = info)
  if(retx) {
    res$x <- as.annmatrix(res$x, rann = attr(x, ".annmatrix.rann"), cann = info)
  }
  res
}
