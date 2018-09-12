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
#' \code{`[.annmatrix`} returns a selected subset of annmatrix object.
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
#' @param rowann annotation \code{data.frame} for rows of the annmatrix object
#' @param colann annotation \code{data.frame} for columns of the annmatrix object
#' @param i subset for rows
#' @param j subset for columns
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param name a character string name of existing row/column annotation field
#' @param value newly assigned value to row/column annotation field
#' @param ... further arguments passed to methods
#'
#' @return
#' \code{annmatrix} - an \code{annmatrix} object.
#'
#' \code{is.annmatrix} - either TRUE or FALSE.
#'
#' \code{annMat@value} - a column named "value" from the row annotation \code{data.frame}
#'
#' \code{annMat$value} - a column named "value" from the column annotation \code{data.frame}
#'
#' \code{`[`.annmatrix} - a subset of  annmatrix and reletad meta-data annotations
#'
#' @examples
#'   coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                         gender=sample(c("M", "F"), 40, replace=TRUE)
#'                         )
#'   rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                         pos=runif(100, 0, 1000000)
#'                         )
#'   mat <- matrix(rnorm(100*40), 100, 40)
#'   annMat <- annmatrix(mat, rowdata, coldata)
#'
#'   is.annmatrix(mat)
#'   is.annmatrix(annMat)
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
annmatrix <- function(x=NULL, rowann=NULL, colann=NULL) {
  if(is.null(x)) x <- matrix(nrow=0, ncol=0)
  if (!is.matrix(x)) x <- as.matrix(x)
  if(is.null(rowann)) rowann <- data.frame(row.names=seq_len(nrow(x)))
  if(is.null(colann)) colann <- data.frame(row.names=seq_len(ncol(x)))
  rowann <- as.data.frame(rowann, stringsAsFactors=FALSE)
  colann <- as.data.frame(colann, stringsAsFactors=FALSE)
  stopifnot(nrow(x)==nrow(rowann) & ncol(x)==nrow(colann))
  attr(x, ".annmatrix.rowann") <- rowann
  attr(x, ".annmatrix.colann") <- colann
  if(!is.annmatrix(x)) class(x) <- append("annmatrix", class(x))
  x
}

#' @rdname core
#' @export
is.annmatrix <- function(x) inherits(x, "annmatrix")

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
`$.annmatrix` <- function(x, name) {
  colann <- attr(x, ".annmatrix.colann")
  if(name==".") {
    colann
  } else {
    colann[[name]]
  }
}

#' @usage \method{@}{annmatrix}(object, name)
#' @rdname core
#' @export
`@.annmatrix` <- function(object, name) {
  name <- deparse(substitute(name))
  rowann <- attr(object, ".annmatrix.rowann")
  if(name==".") {
    rowann
  } else {
    rowann[[name]]
  }
}

#' @rdname core
#' @export
`$<-.annmatrix` <- function(x, name, value) {
  colann <- attr(x, ".annmatrix.colann")
  if(name==".") {
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

#' @usage \method{@}{annmatrix}(object, name) <- value
#' @rdname core
#' @export
`@<-.annmatrix` <- function(object, name, value) {
  name <- deparse(substitute(name))
  rowann <- attr(object, ".annmatrix.rowann")
  if(name==".") {
    if(is.null(value)) {
      rowann <- data.frame(row.names=1:nrow(object))
    } else if(!is.data.frame(value)) {
      stop("row meta data should be a data.frame")
    } else if(nrow(value) != nrow(object)) {
      stop("new row meta data should have the same number of rows as there are rows in the matrix")
    } else {
      rowann <- value
    }
  } else {
    rowann[,name] <- value
  }
  attr(object, ".annmatrix.rowann") <- rowann
  object
}

