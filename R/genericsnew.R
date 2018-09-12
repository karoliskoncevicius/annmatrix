#' New Generics For annmAtrix Class
#'
#' Newly implemented generic methods for annmatrix objects.
#'
#' \code{@} operator in base R is used to access the slots within S4 objects.
#' annmatrix makes this operator generic and uses it to select row-annotations
#' from the \code{annmatrix} class.
#'
#' \code{@<-} replacement in base R is used to change the values of slots within S4 objects.
#' annmatrix makes it generic and the same operator is then used within \code{annmatrix}
#' class to change the row annotation values.
#'
#' @usage object@name
#'
#' @name newgenerics
#'
#' @param object R object
#' @param name a character string name specifying a slot
#' @param value newly assigned value to replace the slot specified by \code{name}
#'
#' @author Karolis Koncevičius
#' @export
`@` <- function(object, name) {
  UseMethod("@")
}

#' @usage object@name
#' @import ethods
#' @rdname newgenerics
#' @export
`@.default` <- function(object, name) {
  methods::slot(object, deparse(substitute(name)))
}

#' @usage object@name <- value
#' @rdname newgenerics
#' @export
`@<-` <- function (object, name, value) {
  UseMethod("@<-")
}

#' @usage object@name <- value
#' @import ethods
#' @rdname newgenerics
#' @export
`@<-.default` <- function(object, name, value) {
  methods::`slot<-`(object, deparse(substitute(name)), check=TRUE, value)
}

