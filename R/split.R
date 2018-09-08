#' Split Matrix by Rows and Columns
#'
#' Splits a \code{matrix} or \code{data.frame} into multiple groups by their rows
#' or columns.
#'
#' @name split
#'
#' @param x an R object. Typically a \code{matrix} or \code{data.frame} to be divided into groups.
#' @param group grouping variable for rows or columns used for dividing an object into groups.
#' Can also be a list of groups in which case their interaction is used for grouping.
#' @param ... further arguments passed to or from methods.
#'
#' @return transposed annmatrix object
#'
#' @examples
#'
#' rowsplit(iris, iris$Species)
#' colsplit(iris, c(1,1,1,1,2))
#'
#' rowsplit(matrix(rnorm(20), nrow=5), c(1,1,2,2,3))
#'
#' @author Karolis Koncevičius
#' @export
rowsplit <- function(x, group, ...) {
  UseMethod("rowsplit")
}

#' @rdname split
#' @export
colsplit <- function(x, group, ...) {
  UseMethod("colsplit")
}

#' @rdname split
#' @export
rowsplit.default <- function(x, group, ...) {
  x <- as.matrix(x)
  split.data.frame(x, group)
}

#' @rdname split
#' @export
colsplit.default <- function(x, group, ...) {
  x <- as.matrix(x)
  Map(t, split.data.frame(t(x), group))
}

#' @rdname split
#' @export
rowsplit.data.frame <- function(x, group, ...) {
  split.data.frame(x, group)
}

#' @rdname split
#' @export
colsplit.data.frame <- function(x, group, ...) {
  split.default(x, group)
}

