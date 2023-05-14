#' Stack an annmatrix object
#'
#' Turns annmatrix into a data frame by transforming the matrix along with row and column annotations into separate data frame columns.
#'
#' @param x annmatrix object.
#' @param ... further arguments passed to or from methods.
#'
#' @return transposed annmatrix object
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
#' # stack all information into a long-format data.frame
#' Y <- stack(X)
#'
#' @author Karolis Koncevičius
#' @name stack
#' @export
stack.annmatrix <- function(x, ...) {
  rann <- attr(x, ".annmatrix.rann")
  cann <- attr(x, ".annmatrix.cann")

  rnx <- rownames(x)
  if (is.null(rnx)) {
    rnx <- 1:nrow(x)
  } else if (is.character(rnx)) {
    rnx <- make.unique(rnx)
  }

  cnx <- colnames(x)
  if (is.null(cnx)) {
    cnx <- 1:ncol(x)
  } else if (is.character(cnx)) {
    cnx <- make.unique(cnx)
  }

  data.frame(value = as.numeric(x),
             rann[rep(seq_len(nrow(rann)), nrow(cann)), , drop = FALSE],
             cann[rep(seq_len(nrow(cann)), each = nrow(rann)), , drop = FALSE],
             row.names = paste(rep(rnx, nrow(cann)), rep(cnx, each = nrow(rann)), sep=":"),
             ...
             )
}
