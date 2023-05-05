#' Group Generic Functions for annmatrix Class
#'
#' The functions listed here work under the hood and are almost never called by the user.
#'
#' @param e1,e2 annmatrix objects.
#' @param x,y The objects being dispatched on by the group generic.
#' @param mx,my The methods found for objects 'x' and 'y'.
#' @param cl The call to the group generic.
#' @param reverse A logical value indicating whether 'x' and 'y' are reversed from the way they were supplied to the generic.
#'
#' @return An object of class 'annmatrix'.
#'
#' @author Karolis Koncevičius
#' @name groupgenerics
#' @export
Ops.annmatrix <- function(e1, e2) {

  if (is.annmatrix(e1)) {
    myclass   <- setdiff(class(e1), "annmatrix")
    pairclass <- oldClass(e2)
    rann <- attr(e1, ".annmatrix.rann")
    cann <- attr(e1, ".annmatrix.cann")
    e1   <- as.matrix(e1)
  } else if (is.annmatrix(e2)) {
    myclass   <- setdiff(class(e2), "annmatrix")
    pairclass <- oldClass(e1)
    rann <- attr(e2, ".annmatrix.rann")
    cann <- attr(e2, ".annmatrix.cann")
    e2   <- as.matrix(e2)
  }

  result <- callGeneric(e1, e2)

  # Only return annmatrix if there is no specific method defined for this operations from the pair class
  # With help from Mikael Jagan on Stack Overflow: https://stackoverflow.com/a/75953638/1953718
  if (is.null(pairclass) ||
      (all(is.na(match(paste0("Ops.", pairclass), .S3methods("Ops")))) &&
       all(is.na(match(paste0(.Generic, ".", pairclass), .S3methods(.Generic)))))) {
    result <- structure(result, class = c("annmatrix", myclass), .annmatrix.rann = rann, .annmatrix.cann = cann)
  }

  result
}

#' @rdname groupgenerics
#' @export
chooseOpsMethod.annmatrix <- function(x, y, mx, my, cl, reverse) {
  TRUE
}
