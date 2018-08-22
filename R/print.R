#' Print annMatrix object.
#'
#' Functions to print an annMatrix object
#'
#' annMatrix objects are printed in a shortened form (10 rows and 10 columns by default).
#' In addition the function displays information about available meta-data for rows and columns.
#'
#' @param annMat a matrix
#' @param nrow number of rows to display
#' @param ncol number of columns to display
#'
#' @return invisibly returns annMatrix object.
#'
#' @examples
#'   print(annMatExample)
#'   print(annMatExample, nrow=2, ncol=2)
#'
#' @author Karolis Koncevicius
#' @export
print.annMatrix <- function(annMat, nrow=10, ncol=10) {
  rows <- nrow(annMat)
  cols <- ncol(annMat)
  if(rows > 0 & cols > 0) {
    mat <- format(annMat[seq_len(min(nrow, rows)), seq_len(min(ncol, cols)), drop=FALSE], digits=5)
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
  cat(names(attr(annMat, "rowAnn")), sep=", ")
  cat("\n")
  cat("columns: ", cols, " ", sep="")
  cat(names(attr(annMat, "colAnn")), sep=", ")
  cat("\n")
  invisible(annMat)
}

