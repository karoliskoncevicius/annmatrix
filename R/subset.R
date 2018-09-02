#' Subset annMatrix object.
#'
#' Functions used to take subsets of annMatrix objects.
#'
#' @param x annMat object
#' @param i subset for rows
#' @param j subset for columns
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param ... further arguments passed to methods
#'
#' @return a subset of annMatrix object with preserved meta-data information
#' for selected rows and columns.
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
#' annMat[1:2,]
#' annMat[,1:2]
#' annMat[1,]
#' annMat[1,,drop=FALSE]
#'
#' @author Karolis Koncevicius
#' @export
`[.annMatrix` <- function(x, i=TRUE, j=TRUE, ..., drop=TRUE) {
  mat <- NextMethod("[")
  if(is.matrix(mat)) {
    attr(mat, ".annMatrix.rowAnn") <- attr(x, ".annMatrix.rowAnn")[i,,drop=drop]
    attr(mat, ".annMatrix.colAnn") <- attr(x, ".annMatrix.colAnn")[j,,drop=drop]
    class(mat) <- append("annMatrix", class(mat))
  }
  mat
}


