#' Technical Generic Functions for annmatrix Class
#'
#' Generic function that help working with the annmatrix class objects easier.
#' These include group generics, auto-completion helpers and similar.
#'
#' The functions listed here work under the hood and are almost never called by
#' the user.
#'
#' @name techgenerics
#'
#' @param x annmatrix object.
#' @param pattern a regular expression used to select the returned auto-completion terms.
#'
#' @import utils
#' @export
.DollarNames.annmatrix <- function(x, pattern="") {
  grep(pattern, names(attr(x, ".annmatrix.colann")), value=TRUE)
}

#' @export
Ops.annmatrix <- function(e1, e2) {
  rowann <- attr(e1, ".annmatrix.rowann")
  colann <- attr(e1, ".annmatrix.colann")

  e1 <- unclass(e1)
  if (!missing(e2)) e2 <- unclass(e2)
  annmatrix(NextMethod(), rowann=rowann, colann=colann)
}

