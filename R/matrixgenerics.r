#' Matrix Generic Functions for annmatrix Class
#'
#' Matrix cross-product operator implemented for annmatrix class
#'
#' The resulting matrix will be the same as a product between two regular matrices.
#' If present annmatrix row annotations will be carried over from the first matrix \code{x}
#' while the annotations for rows will be carried over from the second matrix \code{y}.
#'
#' @param x,y numeric or complex matrices or vectors.
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
