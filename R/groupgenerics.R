#' Group Generic Functions for annmatrix Class
#'
#' The functions listed here work under the hood and are almost never called by the user.
#'
#' @name groupgenerics
#' @param e1,e2 annmatrix objects
#'
#' @export
Ops.annmatrix <- function(e1, e2) {
  if(is.annmatrix(e1)) {
    rann <- attr(e1, ".annmatrix.rann")
    cann <- attr(e1, ".annmatrix.cann")

    e1 <- as.matrix(e1)
    if (!missing(e2)) e2 <- unclass(e2)
    annmatrix(NextMethod(), rann=rann, cann=cann)
  } else if(is.annmatrix(e2)) {
    rann <- attr(e2, ".annmatrix.rann")
    cann <- attr(e2, ".annmatrix.cann")

    e2 <- as.matrix(e2)
    if (!missing(e1)) e1 <- unclass(e1)
    annmatrix(NextMethod(), rann=rann, cann=cann)
  }
}

