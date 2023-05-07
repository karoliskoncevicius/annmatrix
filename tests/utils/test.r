# prints errors without stopping and returns the contents and type of annmatrix as a list
test <- function(expr) {
  res <- try(expr)
  if (class(res)[1] == "annmatrix") {
    print(list(type = typeof(res), matrix = as.matrix(res), rann = attr(res, ".annmatrix.rann"), cann = attr(res, ".annmatrix.cann")))
  } else if (class(res)[1] != "try-error") {
    print(res)
  }
  message(strrep("-", 80))
  message("")
}

