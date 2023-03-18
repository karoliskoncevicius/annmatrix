#' annmatrix Objects and Basic Functionality
#'
#' Functions used to construct, test and use the objects of class \code{annmatrix}.
#'
#' \code{annmatrix} constructs an object of class \code{annmatrix}.
#' The function expects \code{x} to be a \code{matrix}
#' and \code{rowanns} and \code{colanns} to be of class \code{data.frame}.
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
#' \code{rowanns} and \code{colanns} returns the selected field from column and
#' row annotation \code{data.frame} respectively. When the selected field is
#' not specified the whole annotation \code{data.frame} is returned.
#'
#' \code{rowanns<-} and \code{colanns<-} functions can be used to replace the fields from
#' column and row annotation \code{data.frame} respectively. When the selected field
#' is not specified the whole annotation \code{data.frame} is replaced.
#'
#' @name core
#'
#' @param x an R object to be converted, used or tested
#' @param rann annotation \code{data.frame} for rows of the \code{annmatrix} object
#' @param cann annotation \code{data.frame} for columns of the \code{annmatrix} object
#' @param i subset for rows
#' @param j subset for columns
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param names a character vector of existing row/column annotation names
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
#' \code{X@value} - a column named "value" from the row annotation \code{data.frame}
#'
#' \code{X$value} - a column named "value" from the column annotation \code{data.frame}
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
#' x <- matrix(rnorm(100*40), 100, 40)
#' X <- annmatrix(x, rowdata, coldata)
#'
#' is.annmatrix(x)
#' is.annmatrix(X)
#'
#' X[1:2,1:2]
#' X[1,,drop=FALSE]
#'
#' rowanns(X)
#' colanns(X)
#' rowanns(X, "chr")
#' colanns(X, c("group", "gender"))
#'
#' rowanns(X, "newField") <- 1:nrow(X)
#' colanns(X, "newField") <- 1:ncol(X)
#' colanns(X, "newField")
#' colanns(X, "newField") <- NULL
#' colanns(X, "newField")
#'
#' @seealso `$.annmatrix` `@.annmatrix`
#'
#' @author Karolis Koncevičius
#' @export
annmatrix <- function(x, rann, cann) {
  if(missing(x)) x <- matrix(nrow=0, ncol=0)
  x <- as.matrix(x)
  if(missing(rann)) rann <- data.frame(row.names=seq_len(nrow(x)))
  if(missing(cann)) cann <- data.frame(row.names=seq_len(ncol(x)))
  if(is.vector(rann)) rann <- setNames(as.data.frame(rann), deparse(substitute(rann)))
  if(is.vector(cann)) cann <- setNames(as.data.frame(cann), deparse(substitute(cann)))
  rann <- as.data.frame(rann)
  cann <- as.data.frame(cann)
  stopifnot(nrow(x)==nrow(rann) & ncol(x)==nrow(cann))
  attr(x, ".annmatrix.rann") <- rann
  attr(x, ".annmatrix.cann") <- cann
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
  attr(x, ".annmatrix.rann") <- NULL
  attr(x, ".annmatrix.cann") <- NULL
  unclass(x)
}

#' @rdname core
#' @export
`[.annmatrix` <- function(x, i, j, ..., drop=TRUE) {
  mat <- NextMethod("[")
  if(is.matrix(mat)) {
    if(missing(i)) {
      attr(mat, ".annmatrix.rann") <- attr(x, ".annmatrix.rann")
    } else {
      if(is.character(i)) i <- match(i, rownames(x))
      attr(mat, ".annmatrix.rann") <- attr(x, ".annmatrix.rann")[i,,drop=FALSE]
    }
    if(missing(j)) {
      attr(mat, ".annmatrix.cann") <- attr(x, ".annmatrix.cann")
    } else {
      if(is.character(j)) j <- match(j, colnames(x))
      attr(mat, ".annmatrix.cann") <- attr(x, ".annmatrix.cann")[j,,drop=FALSE]
    }
    class(mat) <- append("annmatrix", class(mat))
  }
  mat
}

#' @rdname core
#' @export
colanns <- function(x, names) {
  if(missing(names)) {
    attr(x, ".annmatrix.cann")
  } else if (length(names)==1) {
    attr(x, ".annmatrix.cann")[[names]]
  } else {
    attr(x, ".annmatrix.cann")[,names]
  }
}

#' @rdname core
#' @export
rowanns <- function(x, names) {
  if(missing(names)) {
    attr(x, ".annmatrix.rann")
  } else if(length(names)==1) {
    attr(x, ".annmatrix.rann")[[names]]
  } else {
    attr(x, ".annmatrix.rann")[,names]
  }
}

#' @rdname core
#' @export
`colanns<-` <- function(x, names, value) {
  cann <- attr(x, ".annmatrix.cann")
  if(missing(names)) {
    if(is.null(value)) {
      cann <- data.frame(row.names=1:ncol(x))
    } else if(!is.data.frame(value)) {
      stop("column meta data should be a data.frame")
    } else if(nrow(value) != ncol(x)) {
      stop("new column meta data should have the same number of rows as there are columns in the matrix")
    } else {
      cann <- value
    }
  } else {
    cann[,names] <- value
  }
  attr(x, ".annmatrix.cann") <- cann
  x
}

#' @rdname core
#' @export
`rowanns<-` <- function(x, names, value) {
  rann <- attr(x, ".annmatrix.rann")
  if(missing(names)) {
    if(is.null(value)) {
      rann <- data.frame(row.names=1:nrow(x))
    } else if(!is.data.frame(value)) {
      stop("row meta data should be a data.frame")
    } else if(nrow(value) != nrow(x)) {
      stop("new row meta data should have the same number of rows as there are rows in the matrix")
    } else {
      rann <- value
    }
  } else {
    rann[,names] <- value
  }
  attr(x, ".annmatrix.rann") <- rann
  x
}

