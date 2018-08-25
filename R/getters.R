#' annMatrix getters
#'
#' Functions used to get fields of annMatrix object.
#'
#' Returns selected fields from row and column description annotations.
#' $ is used for selecting column annotations and @ for row annotations.
#'
#' @rdname getter
#'
#' @param annMat annMatrix object.
#' @param rname name of existing row annotation field
#' @param cname name of existing column annotation field
#'
#' @return One-column data frame with selected annotation.
#'
#' @details when a special symbol "." is used instead of a name - the whole
#' annotation data.frame is returned
#'
#' @examples
#'   annMatExample$group
#'   annMatExample@chr
#'   annMatExample$.
#'   annMatExample@.
#'
#' @author Karolis Koncevicius
#' @export
`$.annMatrix` <- function(annMat, cname) {
  colAnn <- attr(annMat, "colAnn")
  if(cname==".") {
    colAnn
  } else {
    colAnn[[cname]]
  }
}

#' @export
.DollarNames.annMatrix <- function(annMat, pattern = "") {
  grep(pattern, names(attr(annMat, "colAnn")), value=TRUE)
}

#' @export
`@` <- function (x, ...) {
  UseMethod("@")
}

#' @export
`@.default` <- function(object, ...) base::`@`(object)

#' @rdname getter
#' @export
`@.annMatrix` <- function(annMat, rname) {
  rname <- deparse(substitute(rname))
  rowAnn <- attr(annMat, "rowAnn")
  if(rname==".") {
    rowAnn
  } else {
    rowAnn[[rname]]
  }
}

