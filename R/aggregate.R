#' Split and Aggregate annmatrix Objects by Rows and Columns
#'
#' A special operator for performing aggregation operatios on rows and columns of \code{annmatrix} objects.
#'
#' \code{`[[`}, when called with 3 arguments or more aggregates the matrix into groups by rows and columns and optionally applies a function to each resulting aggregate.
#'
#' @name aggregate
#'
#' @param x an \code{annmatrix} object
#' @param i vector of length \code(nrow(x)) specifying row-wise groups
#' @param j vector of length \code(ncol(x)) specifying column-wise groups
#' @param ... optional arguments where first argument specifies the function to be applied on each row-colum group and remaining arguments are passed as additional arguments for this function
#' @param drop if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#' @param exact if TRUE (default) the result of subsetting a single row or column is returned as a vector.
#'
#' @return
#' An \code{annmatrix} of lists
#'
#' @examples
#' coldata <- data.frame(group=c(rep("case", 20), rep("control", 20)),
#'                       gender=sample(c("M", "F"), 40, replace=TRUE)
#'                       )
#' rowdata <- data.frame(chr=sample(c("chr1", "chr2"), 100, replace=TRUE),
#'                       pos=runif(100, 0, 1000000)
#'                       )
#' X <- annmatrix(mat, rowdata, coldata)
#'
#' # split X by rows and by columns
#' X[[X@chr, X$gender,]]
#'
#' # calculate mean after splitting
#' X[[X@chr, X$gender, mean]]
#'
#' @author Karolis Koncevičius
#' @export
`[[.annmatrix` <- function(x, i, j, ..., drop=TRUE, exact=TRUE) {
  nargs <- nargs() - 1 - (!missing(drop)) - (!missing(exact))
  if(nargs < 3) {
    mat <- NextMethod("[[")
  } else {
    # adding drop and exact in case user specified them as arguments to some function
    call <- match.call(expand.dots=FALSE)
    dots <- c(call$..., drop=call$drop, exact=call$exact)

    if(is.null(call$i)) i <- rep("1", nrow(x))
    if(is.null(call$j)) j <- rep("1", ncol(x))
    gi <- unique(i)
    gj <- unique(j)

    rann <- rowanns(x)
    if(length(i) != length(gi)) rann <- list2DF(lapply(rann, split, i))
    cann <- colanns(x)
    if(length(j) != length(gj)) cann <- list2DF(lapply(cann, split, j))

    mat <- matrix(list(), nrow=length(gi), ncol=length(gj), dimnames=list(gi,gj))
    for(ii in gi) {
      for(jj in gj) {
        mat[[ii,jj]] <- x[i==ii, j==jj, drop=FALSE]
      }
    }
    mat <- annmatrix(mat, rann, cann)

    if(dots[[1]] != "") {
      args  <- list(...)
      mat   <- apply(mat, 1:2, function(x) do.call(args[[1]], c(x, args[-1])))
      if(!is.null(mat)) {
        mat <- annmatrix(mat, rann, cann)
      }
    }
  }
  mat
}

