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

#' Transform annMatrix object to long format
#'
#' Turns the matrix and it's column and row meta-data into a long-format data.frame.
#'
#' @param annMat annMatrix object
#' @param ... other parameters passed to data.frame()
#'
#' @return data.frame
#'
#' @examples
#'   annMat2Long(annMatExample)
#'
#' @author Karolis Koncevicius
#' @export
annMat2Long <- function(annMat, ...) {
  rowAnn <- attr(annMat, "rowAnn")
  colAnn <- attr(annMat, "colAnn")
  longdf <- data.frame(as.numeric(annMat),
                       rowAnn[rep(seq_len(nrow(rowAnn)), nrow(colAnn)), ],
                       colAnn[rep(seq_len(nrow(colAnn)), each=nrow(rowAnn)), ],
                       ...
                       )
  longdf
}

