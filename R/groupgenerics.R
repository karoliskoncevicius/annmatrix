#' Group Generic Functions for annmatrix Class
#'
#' The functions listed here work under the hood and are almost never called by the user.
#'
#' @name groupgenerics
#' @param e1,e2 annmatrix objects
#'
#' @export
Ops.annmatrix <- function(e1, e2) {
  rowann <- attr(e1, ".annmatrix.rowann")
  colann <- attr(e1, ".annmatrix.colann")

  e1 <- unclass(e1)
  if (!missing(e2)) e2 <- unclass(e2)
  annmatrix(NextMethod(), rowann=rowann, colann=colann)
}

