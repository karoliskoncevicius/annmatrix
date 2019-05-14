#' Print annmatrix object.
#'
#' Functions to print an annmatrix object
#'
#' annmatrix objects are printed in a shortened form (5 rows and 5 columns by default).
#' In addition the function displays information about available meta-data for rows and columns.
#'
#' @param x a matrix
#' @param nrow number of rows to display (default is 5)
#' @param ncol number of columns to display (default is 5)
#' @param ... further arguments passed to or from methods
#'
#' @return invisibly returns annmatrix object.
#'
#' @examples
#' # construct the annmatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annmatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' print(annMat)
#' print(annMat, nrow=2, ncol=2)
#'
#' @author Karolis Koncevičius
#' @export
print.annmatrix <- function(x, nrow=5, ncol=5, ...) {
  rows <- nrow(x)
  cols <- ncol(x)
  rinds <- seq_len(min(nrow, rows))
  cinds <- seq_len(min(ncol, cols))

  if(rows > nrow) rinds <- c(head(rinds, -1), NA, rows)
  if(cols > ncol) cinds <- c(head(cinds, -1), NA, cols)

  mat  <- as.matrix(x[rinds, cinds, drop=FALSE])
  mat  <- format(mat)
  fill <- paste(rep(".", max(0, nchar(mat))), collapse="")
  mat[is.na(rinds),] <- fill
  mat[,is.na(cinds)] <- fill

  rnames <- rownames(mat)
  cnames <- colnames(mat)
  if(is.null(rnames) & rows > 0) {
    rnames <- paste0("[", rinds, ",]")
    rownames(mat) <- format(rnames, justify="right")
  }
  if(is.null(cnames) & cols > 0) {
    cnames <- paste0("[,", cinds, "]")
    cgap   <- max(0, max(0, nchar(mat)) - max(0, nchar(cnames)))
    cnames <- paste0(paste(rep(" ", cgap), collapse=""), cnames)
    colnames(mat) <- format(cnames, justify="right")
  }

  rownames(mat)[is.na(rinds)] <- ""
  colnames(mat)[is.na(cinds)] <- ""


  print.default(mat, justify="left", quote=FALSE)
  cat("\n")

  cat("rann: ")
  cat(names(attr(x, ".annmatrix.rann")), sep=", ")
  cat("\n")

  cat("cann: ")
  cat(names(attr(x, ".annmatrix.cann")), sep=", ")
  cat("\n")

  invisible(x)
}

