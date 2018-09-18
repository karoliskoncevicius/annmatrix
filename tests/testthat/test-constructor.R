context("constructor")

test_that("empty constructor works as expected", {
  mat  <- matrix(nrow=0, ncol=0)
  df   <- data.frame(row.names=NULL)
  amat <- annmatrix()
  expect_equal(as.matrix(amat), mat)
  expect_equal(colanns(amat), df)
  expect_equal(rowanns(amat), df)
  amat2 <- annmatrix(mat, df, df)
  expect_equal(amat, amat2)
})
