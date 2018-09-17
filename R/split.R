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
#'
#' @return transposed annmatrix object
#'
#' @examples
#'
#' rsplit(iris, iris$Species)
#' csplit(iris, c(1,1,1,1,2))
#'
#' rsplit(matrix(rnorm(20), nrow=5), c(1,1,2,2,3))
#'
#' @author Karolis Koncevičius
#' @export
rsplit <- function(x, group) {
  lapply(split(seq_len(nrow(x)), group), function(ind) x[ind, , drop=FALSE])
}

#' @rdname split
#' @export
csplit <- function(x, group) {
  lapply(split(seq_len(ncol(x)), group), function(ind) x[, ind, drop=FALSE])
}

