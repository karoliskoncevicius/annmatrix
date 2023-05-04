#' Scaling and Centering of annmatrix Objects
#'
#' Centers and scales the columns of an annmatrix object.
#'
#' Behaves exactly as \code{scale} on a regular matrix with the preservation of 'annmatrix' class being the only difference.
#'
#' @param x annmatrix object.
#' @param center either a logical value or a numeric vector of length equal to the number of columns of 'x' (default is TRUE).
#' @param scale either a logical value or a numeric vector of length equal to the number of columns of 'x' (default is TRUE).
#'
#' @return The centered and/or scaled annmatrix object with additional attributes "scaled:center" and "scaled:scale" holding the numbers used for centering and scaling of each column.
#'
#' @seealso \code{scale.default}
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
#' scale(X)
#' scale(X, center = colMeans(X))
#'
#' @author Karolis Koncevičius
#' @name scale
#' @export
scale.annmatrix <- function(x) {
  annmatrix(NextMethod(), attr(x, ".annmatrix.rann"), attr(x, ".annmatrix.cann"))
}

