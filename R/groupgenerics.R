#' @export
Ops.annMatrix <- function(e1, e2) {
  annMatrix(NextMethod(),
            rowAnn=attr(e1, ".annMatrix.rowAnn"),
            colAnn=attr(e1, ".annMatrix.colAnn")
            )
}


