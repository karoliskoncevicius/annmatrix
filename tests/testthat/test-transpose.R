context("transpose")


mat <- data.matrix(iris[,-5])
rownames(mat) <- sample(LETTERS, 150, replace=TRUE)
colnames(mat) <- sample(LETTERS, 4)
rdf <- data.frame(Species=as.character(iris$Species), row.names=sample(nrow(mat)))
cdf <- data.frame(Type=sapply(strsplit(colnames(iris)[-5], "\\."), "[", 1),
                  Measure=sapply(strsplit(colnames(iris)[-5], "\\."), "[", 2),
                  row.names=sample(ncol(mat)), stringsAsFactors=FALSE
                  )


test_that("empty annmatrix", {
  amat_empty <- annmatrix()
  expect_equal(t(amat_empty), amat_empty)
})

test_that("double application", {
  amat <- annmatrix(mat, rdf, cdf)
  expect_equal(t(t(amat)), amat)
})

test_that("zero row/col annmatrix", {
  emat <- matrix(nrow=nrow(rdf), ncol=0)
  amat <- annmatrix(emat, rann=rdf)
  expect_equal(as.matrix(t(amat)), t(emat))
  expect_equal(colanns(t(amat)), rdf)
  expect_equal(rowanns(t(amat)), data.frame(row.names=seq_len(ncol(emat))))
  emat <- matrix(nrow=0, ncol=nrow(cdf))
  amat <- annmatrix(emat, cann=cdf)
  expect_equal(as.matrix(t(amat)), t(emat))
  expect_equal(colanns(t(amat)), data.frame(row.names=seq_len(nrow(emat))))
  expect_equal(rowanns(t(amat)), cdf)
})

test_that("one annotation is missing", {
  amat <- annmatrix(mat, rdf, cdf[,NULL])
  expect_equal(t(mat), as.matrix(t(amat)))
  expect_equal(rdf, colanns(t(amat)))
  expect_equal(cdf[,NULL], rowanns(t(amat)))
  amat <- annmatrix(mat, rdf[,NULL], cdf)
  expect_equal(t(mat), as.matrix(t(amat)))
  expect_equal(rdf[,NULL], colanns(t(amat)))
  expect_equal(cdf, rowanns(t(amat)))
})

test_that("both annotations are missing", {
  amat <- annmatrix(mat, rdf[,NULL], cdf[,NULL])
  expect_equal(t(mat), as.matrix(t(amat)))
  expect_equal(rdf[,NULL], colanns(t(amat)))
  expect_equal(cdf[,NULL], rowanns(t(amat)))
})

test_that("full data", {
  amat <- annmatrix(mat, rdf, cdf)
  expect_equal(as.matrix(t(amat)), t(mat))
  expect_equal(colanns(t(amat)), rdf)
  expect_equal(rowanns(t(amat)), cdf)
  tamat <- annmatrix(t(mat), cdf, rdf)
  expect_equal(tamat, t(amat))
  expect_equal(rowanns(tamat), colanns(amat))
  expect_equal(colanns(tamat), rowanns(amat))
})

