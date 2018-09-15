#' New Generic Functions for annmatrix Class
#'
#' \code{@} operator in base R is used to access the slots within S4 objects.
#' \code{annmatrix} makes this operator generic and uses it to select row-annotations
#' from the \code{annmatrix} class.
#'
#' \code{@<-} replacement in base R is used to change the values of slots within S4 objects.
#' \code{annmatrix} makes it generic and the same operator is then used within \code{annmatrix}
#' class to change the row annotation values.
#'
#' @import methods
#' @name shortcutgenerics
#'
#' @param object R object
#' @param name a character string specifying the slot to select/replace
#' @param value newly assigned value to replace the slot specified by \code{name}
#'
#' @author Karolis Koncevičius
#' @export
`@` <- function(object, name) {
  UseMethod("@")
}

#' @rdname shortcutgenerics
#' @export
`@.default` <- function(object, name) {
  methods::slot(object, deparse(substitute(name)))
}

#' @rdname shortcutgenerics
#' @export
`@<-` <- function (object, name, value) {
  UseMethod("@<-")
}

#' @rdname shortcutgenerics
#' @export
`@<-.default` <- function(object, name, value) {
  methods::`slot<-`(object, deparse(substitute(name)), check=TRUE, value)
}


#' Convenient Functions to Access Annotations of annmatrix Objects
#'
#' Shortcuts to access and modify the row and column annotations of the \code{annmatrix} object.
#'
#' \code{@} selects the fields of row metadata \code{data.frame}
#'
#' \code{@<-} replaces the fields of row metadata \code{data.frame}
#'
#' \code{$} selects the fields of column metadata \code{data.frame}
#'
#' \code{$<-} replaces the fields of column metadata \code{data.frame}
#'
#' @name shortcuts
#' @import methods
#' @import utils
#'
#' @param x,object R object
#' @param name a character string specifying the name of metadata to select or replace
#' @param value newly assigned value to replace the field specified by \code{name}
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
#' annMat$group
#' annMat@chr
#'
#' annMat@newField <- 1:nrow(annMat)
#' annMat$newField <- 1:ncol(annMat)
#' annMat$newField
#' annMat$newField <- NULL
#' annMat$newField
#'
#' @author Karolis Koncevičius
#' @export
#' @rdname shortcuts
#' @export
`@.annmatrix` <- function(object, name) {
  name <- deparse(substitute(name))
  if(name=='""') {
    rowann(object)
  } else {
    rowann(object, name)
  }
}

#' @rdname shortcuts
#' @export
`@<-.annmatrix` <- function(object, name, value) {
  name <- deparse(substitute(name))
  if(name=='""') {
    rowann(object) <- value
  } else {
    rowann(object, name) <- value
  }
  object
}

#' @rdname shortcuts
#' @export
`$.annmatrix` <- function(x, name) {
  if(nchar(name)==0) {
    colann(x)
  } else {
    colann(x, name)
  }
}

#' @rdname shortcuts
#' @export
`$<-.annmatrix` <- function(x, name, value) {
  if(nchar(name)==0) {
    colann(x) <- value
  } else {
    colann(x, name) <- value
  }
  x
}


#' Auto Complete Functions for annmatrix Class
#'
#' Function used to select autocomplete options for dollar `$` operator.
#'
#' @import utils
#' @name shortcutautocomplete
#'
#' @param x annmatrix object
#' @param pattern a regular expression used to select possible auto-completion names.
#'
#' @author Karolis Koncevičius
#' @export
.DollarNames.annmatrix <- function(x, pattern="") {
  grep(pattern, names(attr(x, ".annmatrix.colann")), value=TRUE)
}

