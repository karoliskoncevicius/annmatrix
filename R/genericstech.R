#' Technical Generic Functions for annMatrix Class
#'
#' Generic function that help working with the annMatrix class objects easier.
#' These include group generics, auto-completion helpers and similar.
#'
#' The functions listed here work under the hood and are almost never called by
#' the user.
#'
#' @name techgenerics
#'
#' @param x annMatrix object.
#' @param pattern a regular expression used to select the returned auto-completion terms.
#'
#' @import utils
#' @export
.DollarNames.annMatrix <- function(x, pattern="") {
  grep(pattern, names(attr(x, ".annMatrix.colAnn")), value=TRUE)
}

#' @export
Ops.annMatrix <- function(e1, e2) {
  rowAnn <- attr(e1, ".annMatrix.rowAnn")
  colAnn <- attr(e1, ".annMatrix.colAnn")

  e1 <- unclass(e1)
  if (!missing(e2)) e2 <- unclass(e2)
  annMatrix(NextMethod(), rowAnn=rowAnn, colAnn=colAnn)
}

