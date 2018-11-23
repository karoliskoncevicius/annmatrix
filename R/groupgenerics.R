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

    e1 <- unclass(e1)
    if (!missing(e2)) e2 <- unclass(e2)
    annmatrix(NextMethod(), rann=rann, cann=cann)
  } else {
    e2 <- unclass(e2)
    attr(e2, ".annmatrix.cann") <- NULL
    attr(e2, ".annmatrix.rann") <- NULL
    NextMethod()
  }
}

