#' Transpose annMatrix object.
#'
#' Transpose operator for annMatrix object.
#'
#' Transposes the matrix and switches the places of row and column meta-data.
#'
#' @param x annMatrix object
#'
#' @return transposed annMatrix object
#'
#' @examples
#' # construct the annMatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annMatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' t(annMat)
#'
#' @author Karolis Koncevicius
#' @export
t.annMatrix <- function(x) {
  x <- t.default(x)
  rowAnn <- attr(x, ".annMatrix.rowAnn")
  attr(x, ".annMatrix.rowAnn") <- attr(x, ".annMatrix.colAnn")
  attr(x, ".annMatrix.colAnn") <- rowAnn
  x
}

#' Transform annMatrix Object to Long Format
#'
#' Turns the matrix and it's column and row meta-data into a long-format \code{data.frame}.
#'
#' @param x annMatrix object
#' @param ... other parameters passed to \code{data.frame()}
#'
#' @return a \code{data.frame}
#'
#' @examples
#' # construct the annMatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annMatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' annMat2Long(annMat)
#'
#' @author Karolis Koncevicius
#' @export
annMat2Long <- function(x, ...) {
  rowAnn <- attr(x, ".annMatrix.rowAnn")
  colAnn <- attr(x, ".annMatrix.colAnn")
  longdf <- data.frame(as.numeric(x),
                       rowAnn[rep(seq_len(nrow(rowAnn)), nrow(colAnn)), ],
                       colAnn[rep(seq_len(nrow(colAnn)), each=nrow(rowAnn)), ],
                       ...
                       )
  longdf
}

