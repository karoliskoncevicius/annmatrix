#' Print annmatrix Object
#'
#' Functions that print an annmatrix object
#'
#' annmatrix objects are printed in a shortened form (5 rows and 5 columns by default).
#' In addition the function displays information about available meta-data for rows and columns.
#'
#' @param x a matrix.
#' @param nrow number of rows to display (default is 5).
#' @param ncol number of columns to display (default is 5).
#' @param digits number of digits to display (default set to getOptions("digits")).
#' @param ... further arguments passed to or from methods.
#'
#' @return invisibly returns annmatrix object.
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
#' print(X)
#' print(X, 10, 5)
#' print(X, 2, 2)
#'
#' # also works with a list-based matrix
#' x <- matrix(list(mtcars, iris3, USAccDeaths, rivers), ncol=2)
#' print(x)
#' X <- annmatrix(x)
#' print(X)
#'
#' @author Karolis Koncevičius
#' @name print
#' @export
print.annmatrix <- function(x, nrow = 5, ncol = 5, digits = getOption("digits"), ...) {
  rinds <- seq_len(min(nrow, nrow(x)))
  cinds <- seq_len(min(ncol, ncol(x)))

  if (nrow(x) > nrow) {
    rinds <- c(rinds[-length(rinds)], NA, nrow(x))
  }
  if (ncol(x) > ncol) {
    cinds <- c(cinds[-length(cinds)], NA, ncol(x))
  }

  mat <- as.matrix(x[rinds, cinds, drop = FALSE])

  if (is.null(rownames(mat))) {
    rownames(mat) <- ifelse(is.na(rinds), NA, paste0("[", rinds, ",]"))
  }
  if (is.null(colnames(mat))) {
    colnames(mat) <- ifelse(is.na(cinds), NA, paste0("[,", cinds, "]"))
  }

  if (is.list(mat)) {
    dims     <- lapply(mat, function(x) ifelse(is.null(dim(x)), length(x), dim(x)))
    classes  <- sapply(mat, function(x) class(x)[1])
    classes  <- paste0(classes, "<", sapply(dims, paste, collapse = ","), ">")
    mat      <- matrix(classes, nrow = nrow(mat), ncol = ncol(mat), dimnames = dimnames(mat))
  } else if (is.numeric(mat)) {
    mat[!is.na(mat)] <- format(mat[!is.na(mat)], digits = digits)
  } else if (is.character(mat)) {
    mat[]    <- ifelse(is.na(mat), NA, paste0('"', mat, '"'))
  }

  width   <- max(0, nchar(mat), nchar(colnames(mat)), na.rm = TRUE)
  mwidth  <- max(0, nchar(mat), na.rm = TRUE)
  justify <- ifelse(is.numeric(x) | is.logical(x), "right", "left")

  if(!is.character(x)) {
    mat  <- format(mat, width = width, justify = justify)
    fill <- format(strrep(".", mwidth), width = width, justify = justify)
  } else {
    fill  <- strrep(".", mwidth)
  }

  mat[is.na(rinds),] <- fill
  mat[,is.na(cinds)] <- fill

  rownames(mat) <- ifelse(is.na(rinds), "", format(rownames(mat), justify = "right"))
  colnames(mat) <- ifelse(is.na(cinds), "", format(colnames(mat), width = width, justify = "right"))


  print.default(mat, quote = FALSE)
  cat("\n")

  cat("rann: ")
  cat(names(attr(x, ".annmatrix.rann")), sep = ", ")
  cat("\n")

  cat("cann: ")
  cat(names(attr(x, ".annmatrix.cann")), sep = ", ")
  cat("\n")

  invisible(x)
}

