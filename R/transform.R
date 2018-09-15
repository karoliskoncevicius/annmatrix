#' Transpose annmatrix object.
#'
#' Transpose operator for annmatrix object.
#'
#' Transposes the matrix and switches the places of row and column meta-data.
#'
#' @param x annmatrix object
#'
#' @return transposed annmatrix object
#'
#' @examples
#' # construct the annmatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' t(annMat)
#'
#' @author Karolis Koncevičius
#' @export
t.annmatrix <- function(x) {
  x <- t.default(x)
  attnames <- names(attributes(x))
  attnames[match(c(".annmatrix.rowann", ".annmatrix.colann"), attnames)] <- c(".annmatrix.colann", ".annmatrix.rowann")
  names(attributes(x)) <- attnames
  x
}

#' Transform annmatrix Object to Long Format
#'
#' Turns the matrix and it's column and row meta-data into a long-format \code{data.frame}.
#'
#' @param x annmatrix object
#' @param ... other parameters passed to \code{data.frame()}
#'
#' @return a \code{data.frame}
#'
#' @examples
#' # construct the annmatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' annmat2long(annMat)
#'
#' @author Karolis Koncevičius
#' @export
annmat2long <- function(x, ...) {
  rowann <- attr(x, ".annmatrix.rowann")
  colann <- attr(x, ".annmatrix.colann")
  longdf <- data.frame(as.numeric(x),
                       rowann[rep(seq_len(nrow(rowann)), nrow(colann)), ],
                       colann[rep(seq_len(nrow(colann)), each=nrow(rowann)), ],
                       ...
                       )
  longdf
}

