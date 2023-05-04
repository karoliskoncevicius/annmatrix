#' Auto Complete Functions for annmatrix Class
#'
#' Function used to select autocomplete options for dollar `$` and at `@` operators.
#'
#' @param x annmatrix object.
#' @param pattern a regular expression used to select possible auto-completion names.
#'
#' @return A set of possible auto-completion names for row (\code{@}) or column (\code{$}) annotation fields.
#'
#' @author Karolis Koncevičius
#' @name autocomplete
#' @export
.DollarNames.annmatrix <- function(x, pattern = "") {
  findMatches(pattern, names(attr(x, ".annmatrix.cann")))
}

#' @rdname autocomplete
#' @export
.AtNames.annmatrix <- function(x, pattern = "") {
  findMatches(pattern, names(attr(x, ".annmatrix.rann")))
}
