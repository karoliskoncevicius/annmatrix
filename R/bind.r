#' Bind several annmatrix Objects Together
#'
#' Implementation of \code{rbind} and \code{cbind} methods for annmatrix objects.
#'
#' All the inputs are bound together in exact same way as if all the annmatrix objects were regular matrices.
#' Then, the row and column annotations of the supplied annmatrix objects are merged together.
#' Missing annotations are filled in using 'NA' values.
#'
#' More concretely, for \code{rbind} (\code{cbind}) the column (row) annotations are merged together from all the supplied annmatrix objects.
#' Hence the resulting column (row) annotation data.frame will be a union of all the available column (row) annotations.
#' In a case when two annamtrix objects have conflicting annotations (same annotation name with different values) the first occurring instance is selected and an appropriate warning is displayed.
#' For row (column) annotations no conflicts are possible and they are all merged together.
#' When some row (column) annotation table is missing a certain annotation in a particular annmatrix it is filled with missing 'NA' values.
#' For non-annmatrix objects all the row (column) annotations are NA.
#'
#' @param ... (generalized) vector or matrix objects
#'
#' @return a single annmatrix object resulting from binding all the inputs together
#'
#' @examples
#' # construct annmatrix object
#' x <- matrix(rnorm(20*10), 20, 10)
#'
#' coldata <- data.frame(group  = rep(c("case", "control"), each = 5),
#'                       gender = sample(c("M", "F"), 10, replace = TRUE))
#'
#' rowdata <- data.frame(chr = sample(c("chr1", "chr2"), 20, replace = TRUE),
#'                       pos = runif(20, 0, 1000000))
#'
#' X <- annmatrix(x, rowdata, coldata)
#'
#' X1 <- X[1:10,]
#' X2 <- X[11:20,]
#' all.equal(X, rbind(X1, X2))
#'
#'
#' @author Karolis Koncevičius
#' @name bind
#' @export
rbind.annmatrix <- function(...) {
  args  <- list(...)

  # collect all row and column annotations from annmatrix objects
  # then turn all annmatrix objects to regular matrices
  ranns <- vector(length(args), mode = "list")
  canns <- vector(length(args), mode = "list")
  for (i in 1:length(args)) {
    if (is.annmatrix(args[[i]])) {
      ranns[[i]] <- rowanns(args[[i]])
      canns[[i]] <- colanns(args[[i]])
      attr(args[[i]], ".annmatrix.rann") <- NULL
      attr(args[[i]], ".annmatrix.cann") <- NULL
      class(args[[i]]) <- setdiff(class(args[[i]]), "annmatrix")
    }
  }

  # call regular rbind on the arguments without any annmatrix objects
  res <- do.call(rbind, args)

  # we can only safely continue if the resulting object is a regular matrix
  if (all(class(res) == c("matrix", "array"))) {

    # 1. deal with column annotations
    # column annotations will just gain more columns collected from all annmatrix objects
    # so gather all of them as separate entries in a list
    canns <- unlist(canns, recursive = FALSE)

    # when two annmatrices have same column annotations we can safely remove duplicates
    canns <- canns[!duplicated(canns)]

    # but check for entries with same names but different values
    # in case these are detected - take the first occurrence and display a warning
    dups <- duplicated(names(canns))
    if (any(dups)) {
      warning("conflicting annmatrix column annotations - using the ones that occurred first")
      canns <- canns[!dups]
    }

    # restore column annotations in a data.frame format
    canns <- data.frame(canns)

    # 2. deal with row annotations
    # for rows we don't care about duplicates
    # this is because in rbind each row has only one entry of specified annotation
    # first get all the column names from non-empty annotations
    rnames <- unique(unlist(sapply(ranns, names)))

    # then go through the row annotations and adjust them
    for (i in 1:length(ranns)) {

      # if annotation is non-empty then expand it by filling NAs in new columns
      if (!is.null(ranns[[i]])) {
        ranns[[i]][,setdiff(rnames, names(ranns[[i]]))] <- NA

      # if annotation is empty then we need to create a data.frame filled with NAs
      # there will be 3 possibilities:
      # 1) argument was empty (length zero) - create data.frame with 0 rows
      # 2) argument has no dimensions, meaning  it was a vector - create data.frame with 1 rows
      # 3) argument had 2 dimensions - create data.frame with as many rows as there were in argument
      # 4) argument dimension size was above 2 - create data.frame with 1 rows
      } else {
        nr   <- 1
        if (length(args[[i]]) == 0) {
          nr <- 0
        } else if (length(dim(args[[i]])) == 2) {
          nr <- dim(args[[i]])[1]
        }
        ranns[[i]] <- data.frame(matrix(NA, nrow = nr, ncol = length(rnames), dimnames = list(NULL, rnames)))
      }

    }

    # finally bind all the row annotations into a single data.frame
    ranns <- do.call(rbind, ranns)

    res   <- annmatrix(res, rann = ranns, cann = canns)

  }

  res
}

#' @rdname bind
#' @export
cbind.annmatrix <- function(...) {
  args  <- list(...)

  # collect all row and column annotations from annmatrix objects
  # then turn all annmatrix objects to regular matrices
  ranns <- vector(length(args), mode = "list")
  canns <- vector(length(args), mode = "list")
  for (i in 1:length(args)) {
    if (is.annmatrix(args[[i]])) {
      ranns[[i]] <- rowanns(args[[i]])
      canns[[i]] <- colanns(args[[i]])
      attr(args[[i]], ".annmatrix.rann") <- NULL
      attr(args[[i]], ".annmatrix.cann") <- NULL
      class(args[[i]]) <- setdiff(class(args[[i]]), "annmatrix")
    }
  }

  # call regular cbind on the arguments without any annmatrix objects
  res <- do.call(cbind, args)

  # we can only safely continue if the resulting object is a regular matrix
  if (all(class(res) == c("matrix", "array"))) {

    # 1. deal with row annotations
    # row annotations will just gain more columns collected from all annmatrix objects
    # so gather all of them as separate entries in a list
    ranns <- unlist(ranns, recursive = FALSE)

    # when two annmatrices have same row annotations we can safely remove duplicates
    ranns <- ranns[!duplicated(ranns)]

    # but check for entries with same names but different values
    # in case these are detected - take the first occurrence and display a warning
    dups <- duplicated(names(ranns))
    if (any(dups)) {
      warning("conflicting annmatrix row annotations - using the ones that occurred first")
      ranns <- ranns[!dups]
    }

    # restore column annotations in a data.frame format
    ranns <- data.frame(ranns)

    # 2. deal with column annotations
    # for columns we don't care about duplicates
    # this is because in cbind each column has only one entry of specified annotation
    # first get all the column names from non-empty annotations
    cnames <- unique(unlist(sapply(canns, names)))

    # then go through the column annotations and adjust them
    for (i in 1:length(canns)) {

      # if annotation is non-empty then expand it by filling NAs in new columns
      if (!is.null(canns[[i]])) {
        canns[[i]][,setdiff(cnames, names(canns[[i]]))] <- NA

      # if annotation is empty then we need to create a data.frame filled with NAs
      # there will be 3 possibilities:
      # 1) argument was empty (length zero) - create data.frame with 0 rows
      # 2) argument has no dimensions, meaning  it was a vector - create data.frame with 1 rows
      # 3) argument had 2 dimensions - create data.frame with as many rows as there were columns in argument
      # 4) argument dimension size was above 2 - create data.frame with 1 rows
      } else {
        nc   <- 1
        if (length(args[[i]]) == 0) {
          nc <- 0
        } else if (length(dim(args[[i]])) == 2) {
          nc <- dim(args[[i]])[1]
        }
        canns[[i]] <- data.frame(matrix(NA, nrow = nc, ncol = length(cnames), dimnames = list(NULL, cnames)))
      }

    }

    # finally bind all the row annotations into a single data.frame
    canns <- do.call(rbind, canns)

    res   <- annmatrix(res, rann = ranns, cann = canns)

  }

  res
}
