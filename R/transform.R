#' Transpose annMatrix object.
#'
#' Transpose operator for annMatrix object.
#'
#' Transposes the matrix and switches the places of row and column meta-data.
#'
#' @param annMat annMatrix object
#'
#' @return transposed annMatrix object
#'
#' @examples
#'   t(annMatExample)
#'
#' @author Karolis Koncevicius
#' @export
t.annMatrix <- function(annMat) {
  annMat <- t.default(annMat)
  rowAnn <- attr(annMat, "rowAnn")
  attr(annMat, "rowAnn") <- attr(annMat, "colAnn")
  attr(annMat, "colAnn") <- rowAnn
  annMat
}

