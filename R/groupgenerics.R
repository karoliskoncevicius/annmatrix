#' @export
Math.annMatrix <- function(x, ...) {
  annMatrix(NextMethod(), rowAnn=attr(x, "rowAnn"), colAnn=attr(x, "colAnn"))
}

#' @export
Ops.annMatrix <- function(x, ...) {
  annMatrix(NextMethod(), rowAnn=attr(x, "rowAnn"), colAnn=attr(x, "colAnn"))
}


