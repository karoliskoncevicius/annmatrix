#' Subset annmatrix Objects
#'
#' Methods for selecting a set of rows or columns from annmatrix while keeping
#' the associated annotations intact.
#'
#' \code{X[i,j]} returns a selected subset of annmatrix object. Row and column
#' annotations are preserved and subsetted where needed. In the special case
#' when only one column or row is selected in order to be consistent with the
#' \code{matrix} behavior the dimensions of matrix are dropped and a vector is
#' returned. Just like in the case of matrices the additional argument
#' \code{drop=FALSE} can be provided in order to return a proper matrix
#' instead.
#'
#' @param x an R object.
#' @param i subset for rows.
#' @param j subset for columns.
#' @param drop if TRUE (default) subsetting a single row or column will returned a vector.
#' @param ... further arguments passed to or from methods.
#'
#' @seealso \code{as.annmatrix}
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
#' # annotations are preserved after subsetting
#' Y <- X[X@chr == "chr1", X$group == "case"]
#' Y@chr
#' Y$''
#'
#' Y[, 1]
#' Y[, 1, drop = FALSE]
#'
#' @author Karolis Koncevičius
#' @name subset
#' @export
`[.annmatrix` <- function(x, i, j, ..., drop = TRUE) {
  mat <- NextMethod("[")

  if (is.matrix(mat)) {

    if (missing(i)) {
      attr(mat, ".annmatrix.rann") <- attr(x, ".annmatrix.rann")
    } else {
      if (is.character(i)) i <- match(i, rownames(x))
      attr(mat, ".annmatrix.rann") <- attr(x, ".annmatrix.rann")[i,,drop = FALSE]
    }

    if (missing(j)) {
      attr(mat, ".annmatrix.cann") <- attr(x, ".annmatrix.cann")
    } else {
      if (is.character(j)) j <- match(j, colnames(x))
      attr(mat, ".annmatrix.cann") <- attr(x, ".annmatrix.cann")[j,,drop = FALSE]
    }

    class(mat) <- append("annmatrix", oldClass(mat))
  }

  mat
}
