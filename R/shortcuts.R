#' Convenient Getter Functions for Objects of Class annmatrix
#'
#' Shortcuts to access and modify the row and column annotation of the \code{annmatrix} object.
#'
#' \code{@} operator in base R is used to access the slots within S4 objects.
#' \code{annmatrix} makes this operator generic and uses it to select row-annotations
#' from the \code{annmatrix} class.
#'
#' \code{@<-} replacement in base R is used to change the values of slots within S4 objects.
#' \code{annmatrix} makes it generic and the same operator is then used within \code{annmatrix}
#' class to change the row annotation values.
#'
#' \code{$} is used to select data.frame fields of the column metadata.
#'
#' \code{$<-} is used to change the field of a column metadata.
#'
#' @usage object@name
#'
#' @name shortcuts
#' @import methods
#' @import utils
#'
#' @param x, object R object
#' @param name a character string specifying the name of metadata to select or replace
#' @param value newly assigned value to replace the field specified by \code{name}
#' @param pattern a regular expression used to select possible auto-completion names.
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
#'   annMat$group
#'   annMat@chr
#'
#'   annMat@newField <- 1:nrow(annMat)
#'   annMat$newField <- 1:ncol(annMat)
#'   annMat$newField
#'   annMat$newField <- NULL
#'   annMat$newField
#'
#' @author Karolis Koncevičius
#' @export
`@` <- function(object, name) {
  UseMethod("@")
}

#' @usage object@name
#' @rdname shortcuts
#' @export
`@.default` <- function(object, name) {
  methods::slot(object, deparse(substitute(name)))
}

#' @usage \method{@}{annmatrix}(object, name)
#' @rdname shortcuts
#' @export
`@.annmatrix` <- function(object, name) {
  rowann(object, deparse(substitute(name)))
}

#' @usage object@name <- value
#' @rdname shortcuts
#' @export
`@<-` <- function (object, name, value) {
  UseMethod("@<-")
}

#' @usage object@name <- value
#' @rdname shortcuts
#' @export
`@<-.default` <- function(object, name, value) {
  methods::`slot<-`(object, deparse(substitute(name)), check=TRUE, value)
}

#' @usage \method{@}{annmatrix}(object, name) <- value
#' @rdname shortcuts
#' @export
`@<-.annmatrix` <- function(object, name, value) {
  rowann(object, deparse(substitute(name))) <- value
  object
}

#' @rdname shortcuts
#' @export
`$.annmatrix` <- function(x, name) {
  colann(x, name)
}

#' @rdname shortcuts
#' @export
`$<-.annmatrix` <- function(x, name, value) {
  colann(x, name) <- value
  x
}

#' @rdname shortcuts
#' @export
.DollarNames.annmatrix <- function(x, pattern="") {
  grep(pattern, names(attr(x, ".annmatrix.colann")), value=TRUE)
}

