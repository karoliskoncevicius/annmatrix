#' annmatrix Objects and Basic Functionality
#'
#' Functions used to construct, test and use the objects of class \code{annmatrix}.
#'
#' \code{annmatrix} constructs an object of class \code{annmatrix}.
#' The function expects \code{x} to be a \code{matrix}
#' and \code{rowann} and \code{colann} to be of class \code{data.frame}.
#' If the passed objects are of a different class the function will try to
#' convert them via the use of \code{as.matrix} and \code{as.data.frame}.
#'
#' \code{is.annmatrix} checks if the object is an instance of \code{annmatrix}.
#'
#' \code{as.matrix.} will turn an \code{annmatrix} object into plain matrix.
#'
#' \code{`[.`} returns a selected subset of annmatrix object.
#' Row and column meta-data annotations are preserved and subsetted where needed.
#' In the special case when only one column or row is selected - in order to be
#' consistent with the \code{matrix} behavior the dimensions of matrix are
#' dropped and a vector is returned. Just like in the case of matrices the
#' additional argument \code{drop=FALSE} can be provided in order to bypass this
#' and return a proper matrix instead.
#'
#' \code{rowann} and \code{colann} returns the selected field from column and
#' row annotation \code{data.frame} respectively. When the selected field is
#' not specified the whole annotation \code{data.frame} is returned.
#'
#' \code{rowann<-} and \code{colann<-} functions can be used to replace the fields from
#' column and row annotation \code{data.frame} respectively. When the selected field
#' is not specified the whole annotation \code{data.frame} is replaced.
#'
#' @name core
#'
#' @param x an R object to be converted, used or tested
#' @param rowann annotation \code{data.frame} for rows of the \code{annmatrix} object
#' @param colann annotation \code{data.frame} for columns of the \code{annmatrix} object
#' @param i subset for rows
#' @param j subset for columns
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param name a character string name of existing row/column annotation field
#' @param value newly assigned value to row/column annotation field
#' @param ... further arguments passed to or from methods
#'
#' @return
#' \code{annmatrix} - an \code{annmatrix} object
#'
#' \code{is.annmatrix} - either TRUE or FALSE
#'
#' \code{as.matrix} - a \code{matrix} object
#'
#' \code{annMat@value} - a column named "value" from the row annotation \code{data.frame}
#'
#' \code{annMat$value} - a column named "value" from the column annotation \code{data.frame}
#'
#' \code{`[`} - a subset of annmatrix and reletad meta-data annotations
#'
#' @examples
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                       pos=runif(100, 0, 1000000)
#'                       )
#' mat <- matrix(rnorm(100*40), 100, 40)
#' annMat <- annmatrix(mat, rowdata, coldata)
#'
#' is.annmatrix(mat)
#' is.annmatrix(annMat)
#'
#' annMat[1:2,1:2]
#' annMat[1,,drop=FALSE]
#'
#' rowann(annMat)
#' colann(annMat)
#' rowann(annMat, "chr")
#' colann(annMat, "group")
#'
#' rowann(annMat, "newField") <- 1:nrow(annMat)
#' colann(annMat, "newField") <- 1:ncol(annMat)
#' colann(annMat, "newField")
#' colann(annMat, "newField") <- NULL
#' colann(annMat, "newField")
#'
#' @seealso `$.annmatrix` `@.annmatrix`
#'
#' @author Karolis Koncevičius
#' @export
annmatrix <- function(x=NULL, rowann=NULL, colann=NULL) {
  if(is.null(x)) x <- matrix(nrow=0, ncol=0)
  x <- as.matrix(x)
  if(is.null(rowann)) rowann <- data.frame(row.names=seq_len(nrow(x)))
  if(is.null(colann)) colann <- data.frame(row.names=seq_len(ncol(x)))
  rowann <- as.data.frame(rowann, stringsAsFactors=FALSE)
  colann <- as.data.frame(colann, stringsAsFactors=FALSE)
  stopifnot(nrow(x)==nrow(rowann) & ncol(x)==nrow(colann))
  attr(x, ".annmatrix.rowann") <- rowann
  attr(x, ".annmatrix.colann") <- colann
  class(x) <- append("annmatrix", class(x))
  x
}

#' @rdname core
#' @export
is.annmatrix <- function(x) {
  inherits(x, "annmatrix")
}

#' @rdname core
#' @export
as.matrix.annmatrix <- function(x, ...) {
  attr(x, ".annmatrix.rowann") <- NULL
  attr(x, ".annmatrix.colann") <- NULL
  unclass(x)
}

#' @rdname core
#' @export
`[.annmatrix` <- function(x, i, j, ..., drop=TRUE) {
  mat <- NextMethod("[")
  if(is.matrix(mat)) {
    if(missing(i)) {
      attr(mat, ".annmatrix.rowann") <- attr(x, ".annmatrix.rowann")
    } else {
      attr(mat, ".annmatrix.rowann") <- attr(x, ".annmatrix.rowann")[i,,drop=FALSE]
    }
    if(missing(j)) {
      attr(mat, ".annmatrix.colann") <- attr(x, ".annmatrix.colann")
    } else {
      attr(mat, ".annmatrix.colann") <- attr(x, ".annmatrix.colann")[j,,drop=FALSE]
    }
    class(mat) <- append("annmatrix", class(mat))
  }
  mat
}

#' @rdname core
#' @export
colann <- function(x, name=NULL) {
  if(is.null(name)) {
    attr(x, ".annmatrix.colann")
  } else {
    attr(x, ".annmatrix.colann")[[name]]
  }
}

#' @rdname core
#' @export
rowann <- function(x, name=NULL) {
  if(is.null(name)) {
    attr(x, ".annmatrix.rowann")
  } else {
    attr(x, ".annmatrix.rowann")[[name]]
  }
}

#' @rdname core
#' @export
`colann<-` <- function(x, name=NULL, value) {
  colann <- attr(x, ".annmatrix.colann")
  if(is.null(name)) {
    if(is.null(value)) {
      colann <- data.frame(row.names=1:ncol(x))
    } else if(!is.data.frame(value)) {
      stop("column meta data should be a data.frame")
    } else if(nrow(value) != ncol(x)) {
      stop("new column meta data should have the same number of rows as there are columns in the matrix")
    } else {
      colann <- value
    }
  } else {
    colann[,name] <- value
  }
  attr(x, ".annmatrix.colann") <- colann
  x
}

#' @rdname core
#' @export
`rowann<-` <- function(x, name=NULL, value) {
  rowann <- attr(x, ".annmatrix.rowann")
  if(is.null(name)) {
    if(is.null(value)) {
      rowann <- data.frame(row.names=1:ncol(x))
    } else if(!is.data.frame(value)) {
      stop("row meta data should be a data.frame")
    } else if(nrow(value) != ncol(x)) {
      stop("new row meta data should have the same number of rows as there are rows in the matrix")
    } else {
      rowann <- value
    }
  } else {
    rowann[,name] <- value
  }
  attr(x, ".annmatrix.rowann") <- rowann
  x
}

