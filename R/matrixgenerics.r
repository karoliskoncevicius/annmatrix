#s' Matrix Generic Functions for annmatrix Class
#'
#' Matrix cross-product operator implemented for annmatrix class
#'
#' The resulting matrix will be the same as a product between two regular matrices.
#' If present annmatrix row annotations will be carried over from the first matrix \code{x}
#' while the annotations for rows will be carried over from the second matrix \code{y}.
#'
#' @param x,y numeric or complex matrices or vectors.
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
#' X <- annmatrix(x, rowdata, coldata)
#'
#' res <- 1:20 %*% X
#' res$group
#'
#' res <- X %*% 1:10
#' res@chr
#'
#' res <- t(X) %*% X
#' res@group
#' res$group
#'
#' @author Karolis Koncevičius
#' @name matrixgenerics
#' @export
`%*%.annmatrix` <- function(x, y) {

  x <- unclass(x)
  y <- unclass(y)
  result <- x %*% y

  rann <- attr(x, ".annmatrix.rann")
  cann <- attr(y, ".annmatrix.cann")

  annmatrix(result, rann, cann)
}
