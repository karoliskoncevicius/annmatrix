#' Print annMatrix object.
#'
#' Functions to print an annMatrix object
#'
#' annMatrix objects are printed in a shortened form (5 rows and 5 columns by default).
#' In addition the function displays information about available meta-data for rows and columns.
#'
#' @param x a matrix
#' @param nrow number of rows to display (default is 5)
#' @param ncol number of columns to display (default is 5)
#' @param ... further arguments passed to or from methods
#'
#' @return invisibly returns annMatrix object.
#'
#' @examples
#' # construct the annMatrix object
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                          pos=runif(100, 0, 1000000)
#'                          )
#' annMat <- annMatrix(matrix(rnorm(100*40), 100, 40), rowdata, coldata)
#'
#' print(annMat)
#' print(annMat, nrow=2, ncol=2)
#'
#' @author Karolis Koncevicius
#' @export
print.annMatrix <- function(x, nrow=5, ncol=5, ...) {
  rows <- nrow(x)
  cols <- ncol(x)
  if(rows > 0 & cols > 0) {
    mat <- format(x[seq_len(min(nrow, rows)), seq_len(min(ncol, cols)), drop=FALSE], digits=5)
    if(rows > nrow) {
      mat <- rbind(mat, "...")
    }
    if(cols > ncol) {
      mat <- cbind(mat, "...")
    }
    print.default(format(mat, justify="right"), quote=FALSE)
    cat("\n")
  }
  cat("rows:    ", rows, " ", sep="")
  cat(names(attr(x, ".annMatrix.rowAnn")), sep=", ")
  cat("\n")
  cat("columns: ", cols, " ", sep="")
  cat(names(attr(x, ".annMatrix.colAnn")), sep=", ")
  cat("\n")
  invisible(x)
}

