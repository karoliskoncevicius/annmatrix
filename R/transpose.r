#' Transposing annmatrix Objects
#'
#' Transpose annmatrix along with the associated row and column annotations.
#'
#' @param x annmatrix object.
#'
#' @return transposed annmatrix object with appropriately adjusted row and column annotations.
#'
#' @examples
#' # construct annmatrix object
#' x <- matrix(rnorm(20*10), 20, 10)
#'
#' coldata <- data.frame(group  = rep(c("case", "control"), each = 5),
#'                       gender = sample(c("M", "F"), 10, replace = TRUE))
#'
#' rowdata <- data.frame(chr = sample(c("chr1", "chr2"), 20, replace = TRUE),
#'                       pos = runif(20, 0, 1000000))
#'
#' X <- annmatrix(x, rowdata, coldata)
#'
#' # transposes the main matrix along with row and column annotations
#' Xt <- t(X)
#'
#' print(X)
#' print(Xt)
#'
#' X@chr
#' Xt$chr
#'
#' @author Karolis Koncevičius
#' @name transpose
#' @export
t.annmatrix <- function(x) {
  x <- t.default(x)
  attnames <- names(attributes(x))
  attnames[match(c(".annmatrix.rann", ".annmatrix.cann"), attnames)] <- c(".annmatrix.cann", ".annmatrix.rann")
  names(attributes(x)) <- attnames
  x
}

