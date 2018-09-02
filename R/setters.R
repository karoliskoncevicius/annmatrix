#' annMatrix setters
#'
#' Functions used to change the fields of annMatrix object.
#'
#' Modifies the selected fields from row and column description annotations.
#' $ is used for selecting column annotations and @ for row annotations.
#'
#' @rdname setter
#'
#' @param x annMatrix object.
#' @param object annMatrix object.
#' @param name name of existing row/column annotation field
#' @param value assigned value
#'
#' @return annMatrix object with modified fields.

#' @details when a special symbol "." is used instead of a name - the whole
#' annotation data.frame is replaced
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
#' annMat@newField <- 1:nrow(annMat)
#' annMat$newField <- 1:ncol(annMat)
#'
#' @author Karolis Koncevicius
#' @export
`$<-.annMatrix` <- function(x, name, value) {
  colAnn <- attr(x, ".annMatrix.colAnn")
  if(name==".") {
    if(is.null(value)) {
      colAnn <- data.frame(row.names=1:ncol(x))
    } else if(!is.data.frame(value)) {
      stop("column meta data should be a data.frame")
    } else if(nrow(value) != ncol(x)) {
      stop("new column meta data should have the same number of rows as there are columns in the matrix")
    } else {
      colAnn <- value
    }
  } else {
    colAnn[,name] <- value
  }
  attr(x, ".annMatrix.colAnn") <- colAnn
  x
}

#' @rdname setter
#' @export
`@<-` <- function (object, name, value) {
  UseMethod("@<-")
}

#' @export
`@<-.default` <- function(object, name, value) base::`@<-`(object, name, value)

#' @rdname setter
#' @export
`@<-.annMatrix` <- function(object, name, value) {
  name <- deparse(substitute(name))
  rowAnn <- attr(object, ".annMatrix.rowAnn")
  if(name==".") {
    if(is.null(value)) {
      rowAnn <- data.frame(row.names=1:nrow(object))
    } else if(!is.data.frame(value)) {
      stop("row meta data should be a data.frame")
    } else if(nrow(value) != nrow(object)) {
      stop("new row meta data should have the same number of rows as there are rows in the matrix")
    } else {
      rowAnn <- value
    }
  } else {
    rowAnn[,name] <- value
  }
  attr(object, ".annMatrix.rowAnn") <- rowAnn
  object
}

