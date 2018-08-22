#' annMatrix setters
#'
#' Functions used to change the fields of annMatrix object.
#'
#' Modifies the selected fields from row and column description annotations.
#' $ is used for selecting column annotations and @ for row annotations.
#'
#' @name setter
#'
#' @param annMat annMatrix object.
#' @param rname name of existing row annotation field
#' @param cname name of existing column annotation field
#' @param value assigned value
#'
#' @return annMatrix object with modified fields.

#' @details when a special symbol "." is used instead of a name - the whole
#' annotation data.frame is replaced
#'
#' @examples
#'    annMatExample@newField <- 1:nrow(annMatExample)
#'    annMatExample$newField <- 1:ncol(annMatExample)
#'
#' @author Karolis Koncevicius
#' @export
`$<-.annMatrix` <- function(annMat, cname, value) {
  colAnn <- attr(annMat, "colAnn")
  if(cname==".") {
    if(is.null(value)) {
      colAnn <- data.frame(row.names=1:ncol(annMat))
    } else if(!is.data.frame(value)) {
      stop("column meta data should be a data.frame")
    } else if(nrow(value) != ncol(annMat)) {
      stop("new column meta data should have the same number of rows as there are columns in the matrix")
    } else {
      colAnn <- value
    }
  } else {
    colAnn[,cname] <- value
  }
  attr(annMat, "colAnn") <- colAnn
  annMat
}

`@<-` <- function (x, ...) {
  UseMethod("@<-", x)
}

`@<-.default` <- base::`@<-`

#' @rdname getter
#' @export
`@<-.annMatrix` <- function(annMat, rname, value) {
  rname <- deparse(substitute(rname))
  rowAnn <- attr(annMat, "rowAnn")
  if(rname==".") {
    if(is.null(value)) {
      rowAnn <- data.frame(row.names=1:nrow(annMat))
    } else if(!is.data.frame(value)) {
      stop("row meta data should be a data.frame")
    } else if(nrow(value) != nrow(annMat)) {
      stop("new row meta data should have the same number of rows as there are rows in the matrix")
    } else {
      rowAnn <- value
    }
  } else {
    rowAnn[,rname] <- value
  }
  attr(annMat, "rowAnn") <- rowAnn
  annMat
}

