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
#' X <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' t(X)
#'
#' @author Karolis Koncevičius
#' @export
t.annmatrix <- function(x) {
  x <- t.default(x)
  attnames <- names(attributes(x))
  attnames[match(c(".annmatrix.rann", ".annmatrix.cann"), attnames)] <- c(".annmatrix.cann", ".annmatrix.rann")
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
#' X <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' annmat2long(X)
#'
#' @author Karolis Koncevičius
#' @export
annmat2long <- function(x, ...) {
  rann <- attr(x, ".annmatrix.rann")
  cann <- attr(x, ".annmatrix.cann")
  data.frame(value=as.numeric(x),
             rann[rep(seq_len(nrow(rann)), nrow(cann)), , drop=FALSE],
             cann[rep(seq_len(nrow(cann)), each=nrow(rann)), , drop=FALSE],
             ...
             )
}

#' Transform annmatrix Object to List Format
#'
#' Turns the matrix and it's column and row meta-data into a \code{list}.
#'
#' @param x annmatrix object
#' @param ... other parameters passed to \code{list}
#'
#' @return a \code{list}
#'
#' @examples
#' # construct the annmatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' X <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' annmat2list(X)
#'
#' @author Karolis Koncevičius
#' @export
annmat2list <- function(x, ...) {
  rann <- attr(x, ".annmatrix.rann")
  cann <- attr(x, ".annmatrix.cann")
  list(mat=as.matrix(x), rowanns=rann, colanns=cann, ...)
}

