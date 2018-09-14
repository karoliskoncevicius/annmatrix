context("constructor")

test_that("empty constructor works as expected", {
  mat <- annmatrix()
  expect_equal(dim(mat), c(0,0))
})
