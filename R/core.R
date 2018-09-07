#' annMatrix Objects and Basic Functionality
#'
#' Functions used to construct, test and use the objects of class \code{annMatrix}.
#'
#' \code{annMatrix} constructs an object of class \code{annMatrix}.
#' The function expects \code{x} to be a \code{matrix}
#' and \code{rowAnn} and \code{colAnn} to be of class \code{data.frame}.
#' If the passed objects are of a different class the function will try to
#' convert them via the use of \code{as.matrix} and \code{as.data.frame}.
#'
#' \code{is.annMatrix} checks if the object is an instance of \code{annMatrix}.
#'
#' \code{`[.annMatrix`} returns a selected subset of annMatrix object.
#' Row and column meta-data annotations are preserved and subsetted where needed.
#' In the special case when only one column or row is selected - in order to be
#' consistent with the \code{matrix} behavior the dimensions of matrix are
#' dropped and a vector is returned. Just like in the case of matrices the
#' additional argument \code{drop=FALSE} can be provided in order to bypass this
#' and return a proper matrix instead.
#'
#' \code{$} and \code{@} returns the selected field from column and row annotation
#' \code{data.frame} respectively. When a special symbol "." is used instead of
#' the field name - the whole annotation \code{data.frame} is returned.
#'
#' \code{$<-} and \code{@<-} functions can be used to replace the fields from
#' column and row annotation \code{data.frame} respectively. When a special
#' symbol "." is used instead of a name - the whole annotation \code{data.frame}
#' is replaced.
#'
#' @name core
#'
#' @param x,object an R object to be converted, used or tested
#' @param rowAnn annotation \code{data.frame} for rows of the annMatrix object
#' @param colAnn annotation \code{data.frame} for columns of the annMatrix object
#' @param i subset for rows
#' @param j subset for columns
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param name a character string name of existing row/column annotation field
#' @param value newly assigned value to row/column annotation field
#' @param ... further arguments passed to methods
#'
#' @return
#' \code{annMatrix} - an \code{annMatrix} object.
#'
#' \code{is.annMatrix} - either TRUE or FALSE.
#'
#' \code{annMat@value} - a column named "value" from the row annotation \code{data.frame}
#'
#' \code{annMat$value} - a column named "value" from the column annotation \code{data.frame}
#'
#' \code{`[`.annMatrix} - a subset of  annMatrix and reletad meta-data annotations
#'
#' @examples
#'   coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                         gender=sample(c("M", "F"), 40, replace=TRUE)
#'                         )
#'   rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                         pos=runif(100, 0, 1000000)
#'                         )
#'   mat <- matrix(rnorm(100*40), 100, 40)
#'   annMat <- annMatrix(mat, rowdata, coldata)
#'
#'   is.annMatrix(mat)
#'   is.annMatrix(annMat)
#'
#'   annMat[1:2,1:2]
#'   annMat[1,,drop=FALSE]
#'
#'   annMat$group
#'   annMat@chr
#'   annMat$.
#'   annMat@.
#'
#'   annMat@newField <- 1:nrow(annMat)
#'   annMat$newField <- 1:ncol(annMat)
#'   annMat$newField
#'   annMat$newField <- NULL
#'   annMat$newField
#'
#' @author Karolis Koncevičius
#' @export
annMatrix <- function(x=NULL, rowAnn=NULL, colAnn=NULL) {
  if(is.null(x)) x <- matrix(nrow=0, ncol=0)
  x <- as.matrix(x)
  if(is.null(rowAnn)) rowAnn <- data.frame(row.names=seq_len(nrow(x)))
  if(is.null(colAnn)) colAnn <- data.frame(row.names=seq_len(ncol(x)))
  rowAnn <- as.data.frame(rowAnn, stringsAsFactors=FALSE)
  colAnn <- as.data.frame(colAnn, stringsAsFactors=FALSE)
  stopifnot(nrow(x)==nrow(rowAnn) & ncol(x)==nrow(colAnn))
  attr(x, ".annMatrix.rowAnn") <- rowAnn
  attr(x, ".annMatrix.colAnn") <- colAnn
  class(x) <- append("annMatrix", class(x))
  x
}

#' @rdname core
#' @export
is.annMatrix <- function(x) inherits(x, "annMatrix")

#' @rdname core
#' @export
`[.annMatrix` <- function(x, i=TRUE, j=TRUE, ..., drop=TRUE) {
  mat <- NextMethod("[")
  if(is.matrix(mat)) {
    attr(mat, ".annMatrix.rowAnn") <- attr(x, ".annMatrix.rowAnn")[i,,drop=drop]
    attr(mat, ".annMatrix.colAnn") <- attr(x, ".annMatrix.colAnn")[j,,drop=drop]
    class(mat) <- append("annMatrix", class(mat))
  }
  mat
}

#' @rdname core
#' @export
`$.annMatrix` <- function(x, name) {
  colAnn <- attr(x, ".annMatrix.colAnn")
  if(name==".") {
    colAnn
  } else {
    colAnn[[name]]
  }
}

#' @usage \method{@}{annMatrix}(object, name)
#' @rdname core
#' @export
`@.annMatrix` <- function(object, name) {
  name <- deparse(substitute(name))
  rowAnn <- attr(object, ".annMatrix.rowAnn")
  if(name==".") {
    rowAnn
  } else {
    rowAnn[[name]]
  }
}

#' @rdname core
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

#' @usage \method{@}{annMatrix}(object, name) <- value
#' @rdname core
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

