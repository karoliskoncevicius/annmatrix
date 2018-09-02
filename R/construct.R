#' Construct annMatrix object.
#'
#' Functions used to construct the annMatrix object.
#'
#' annMatrix constructs an object of class annMatrix.
#'
#' is.annMatrix checks if the object is an instance of class annMatrix.
#'
#' @name construct
#'
#' @param mat a matrix
#' @param rowAnn annotation data.frame for rows of the mat matrix.
#' @param colAnn annotation data.frame for columns of the mat matrix.
#'
#' @return annMatrix() - an annMatrix object.
#'
#'   is.annMatrix() - either TRUE or FALSE.
#'
#' @examples
#'   ints <- matrix(rnorm(200), ncol=10, nrow=20)
#'   gmap <- data.frame(chr=sample(c("chr1", "chr2"), 20, replace=TRUE))
#'   key  <- data.frame(Lot=sample(10, replace=TRUE), ID=10:1)
#'   newAnnMat <- annMatrix(ints, gmap, key)
#'
#'   is.annMatrix(ints)
#'   is.annMatrix(newAnnMat)
#'
#' @author Karolis Koncevicius
#' @export
annMatrix <- function(mat=NULL, rowAnn=NULL, colAnn=NULL) {
  if(is.null(mat)) mat <- matrix(nrow=0, ncol=0)
  mat <- as.matrix(mat)
  if(is.null(rowAnn)) rowAnn <- data.frame(row.names=seq_len(nrow(mat)))
  if(is.null(colAnn)) colAnn <- data.frame(row.names=seq_len(ncol(mat)))
  rowAnn <- data.frame(rowAnn, stringsAsFactors=FALSE)
  colAnn <- data.frame(colAnn, stringsAsFactors=FALSE)
  stopifnot(nrow(mat)==nrow(rowAnn) & ncol(mat)==nrow(colAnn))
  attr(mat, "rowAnn") <- rowAnn
  attr(mat, "colAnn") <- colAnn
  class(mat) <- append("annMatrix", class(mat))
  mat
}

#' @rdname construct
#' @param x an R object.
#' @export
is.annMatrix <- function(x) inherits(x, "annMatrix")

