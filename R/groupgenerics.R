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
    structure(NextMethod(), class=c("annmatrix", class(e1)), .annmatrix.rann=rann, .annmatrix.cann=cann)
  } else if(is.annmatrix(e2)) {
    rann <- attr(e2, ".annmatrix.rann")
    cann <- attr(e2, ".annmatrix.cann")

    e2 <- as.matrix(e2)
    structure(NextMethod(), class=c("annmatrix", class(e2)), .annmatrix.rann=rann, .annmatrix.cann=cann)
  }
}

# TODO: take a look at chooseOpsMethod() once R 4.3.0 is out
#       check problems with X + Sys.Date()
#       need to make sure matrix and annmatrix performs the same
