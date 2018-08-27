#' @export
Ops.annMatrix <- function(e1, e2) {
  annMatrix(NextMethod(), rowAnn=attr(e1, "rowAnn"), colAnn=attr(e1, "colAnn"))
}


