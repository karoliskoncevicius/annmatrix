#' Subset annMatrix object.
#'
#' Functions used to take subsets of annMatrix objects.
#'
#' @param annMat annMat object
#' @param i subset for rows
#' @param j subset for columns
#'
#' @return a subset of annMatrix object with preserved meta-data information
#' for selected rows and columns.
#'
#' @examples
#'   annMatExample[1:2,]
#'   annMatExample[,1:2]
#'   annMatExample[1,]
#'   annMatExample[1,,drop=FALSE]
#'
#' @author Karolis Koncevicius
#' @export
`[.annMatrix` <- function(annMat, i=TRUE, j=TRUE, ...) {
  mat <- NextMethod("[")
  if(is.matrix(mat)) {
    attr(mat, "rowAnn") <- attr(annMat, "rowAnn")[i,,drop=FALSE]
    attr(mat, "colAnn") <- attr(annMat, "colAnn")[j,,drop=FALSE]
    class(mat) <- append("annMatrix", class(mat))
  }
  mat
}


