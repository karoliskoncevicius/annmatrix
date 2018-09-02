#' annMatrix getters
#'
#' Functions used to get fields of annMatrix object.
#'
#' Returns selected fields from row and column description annotations.
#' $ is used for selecting column annotations and @ for row annotations.
#'
#' @rdname getter
#'
#' @param x annMatrix object.
#' @param object annMatrix object.
#' @param name name of existing row/column annotation field
#'
#' @return One-column data frame with selected annotation.
#'
#' @details when a special symbol "." is used instead of a name - the whole
#' annotation data.frame is returned
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
#' annMat$group
#' annMat@chr
#' annMat$.
#' annMat@.
#'
#' @author Karolis Koncevicius
#' @export
`$.annMatrix` <- function(x, name) {
  colAnn <- attr(x, ".annMatrix.colAnn")
  if(name==".") {
    colAnn
  } else {
    colAnn[[name]]
  }
}

#' @import utils
#' @export
.DollarNames.annMatrix <- function(x, pattern="") {
  grep(pattern, names(attr(x, ".annMatrix.colAnn")), value=TRUE)
}

#' @rdname getter
#' @export
`@` <- function (object, name) {
  UseMethod("@")
}

#' @export
`@.default` <- function(object, name) base::`@`(object, name)

#' @rdname getter
#' @export
`@.annMatrix` <- function(object, name) {
  name <- deparse(substitute(name))
  rowAnn <- attr(object, ".annMatrix.rowAnn")
  if(name==".") {
    rowAnn
  } else {
    rowAnn[[name]]
  }
}

