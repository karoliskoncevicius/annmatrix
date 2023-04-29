# annmatrix #

R Annotated Matrix Object

![illustration](http://karolis.koncevicius.lt/data/annmatrix/illustration.png)


## Description ##

`annmatrix` object implements persistent row and column annotations for R matrices.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But 'annmatrix' is readily applicable in other contexts where the data can be assembled into a matrix form with rows and columns representing distinct type of information.

The main advantage of 'annmatrix' over BioConductor implementations like [SummarizedExperiment](https://bioconductor.org/packages/release/bioc/html/SummarizedExperiment.html) and [AnnotatedDataFrame](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame) is simplicity.
Since 'annmatrix' is based on a regular matrix, and not a list or a data frame, it behaves like a regular matrix and can be directly passed to various methods that expect a matrix for an input.


## Installation ##

Using `remotes` library:

```r
remotes::install_github("karoliskoncevicius/annmatrix")
```


## Demonstration ##

Say, you have a small gene expression dataset with 10 genes measured across 6 samples.

```r
mat <- matrix(rnorm(10 * 6), nrow = 10, ncol = 6)
```

And some additional information about those genes and samples.

```r
# sample annotations
group   <- rep(c("case", "control"), each=3)
gender  <- sample(c("M", "F"), 6, replace = TRUE)

coldata <- data.frame(group = group, gender = gender)

# gene annotations
chromosome <- sample(c("chr1", "chr2", "chr3"), 10, replace = TRUE)
position   <- runif(10, 0, 1000000)

rowdata <- data.frame(chr = chromosome, pos = position)
```

`annmatrix` allows you to attach this additional information to the rows and columns of the original matrix.

```r
X <- annmatrix(mat, rowdata, coldata)
```

When printed `annmatrix` shows 4 first + the last row and 4 first + the last column from the matrix.
All the available row and column annotations are listed under the printed matrix.

```r
X

             [,1]        [,2]        [,3]        [,4]                    [,6]
 [1,]  0.66169350 -0.30735899  1.05689046 -0.12608955 ........... -0.57256277
 [2,]  0.68271345  1.40599511  0.61957934  0.14596230 ........... -1.69882580
 [3,] -2.78862062  1.16731768 -0.31053865  0.17378339 ........... -1.20254675
 [4,] -0.01664427 -0.97852517 -0.90142778  0.64705772 ...........  0.29171123
      ........... ........... ........... ........... ........... ...........
[10,] -0.96844681  1.29051415  1.25168520  1.15311914 ...........  0.93371761

rann: chr, pos
cann: group, gender
```

Custom operators `@` and `$` are provided for convenient manipulation of row and column metadata.


```r
X@chr
 [1] "chr1" "chr3" "chr2" "chr2" "chr1" "chr2" "chr3" "chr3" "chr2" "chr3"
```

```r
X$group
 [1] "case"    "case"    "case"    "control" "control" "control"
```

They also can be used in adjust the annotations.

```r
X@chr <- "chr2"
X@chr
 [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
```

Or create new ones.

```r
X$age <- seq(10, 60, 10)
X$age
 [1] 10 20 30 40 50 60
```

When an empty name is provided it will return the whole annotation `data.frame`.

```r
X$''
    group gender age
1    case      F  10
2    case      F  20
3    case      M  30
4 control      F  40
5 control      M  50
6 control      M  60
```

When subsetting the `annmatrix` object all the annotations are correctly adjusted and class is preserved.


```r
X_case <- X[, X$group == "case"]
X_case
             [,1]        [,2]        [,3]
 [1,]  0.66169350 -0.30735899  1.05689046
 [2,]  0.68271345  1.40599511  0.61957934
 [3,] -2.78862062  1.16731768 -0.31053865
 [4,] -0.01664427 -0.97852517 -0.90142778
      ........... ........... ...........
[10,] -0.96844681  1.29051415  1.25168520

rann: chr, pos
cann: group, gender, age
```

```r
X_case$''
  group gender age
1  case      F  10
2  case      F  20
3  case      M  30
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column.

```r
X[1,]
 [1]  0.6616935 -0.3073590  1.0568905 -0.1260895 -1.7833199 -0.5725628
```

But just like with a matrix we can enforce it to preserve all the annotations and class by setting `drop=FALSE`.


```r
X[1,, drop=FALSE]
           [,1]       [,2]       [,3]       [,4]                  [,6]
[1,]  0.6616935 -0.3073590  1.0568905 -0.1260895 .......... -0.5725628

rann: chr, pos
cann: group, gender, age
```

Operations on `annmatrix` object don't loose the class.


```r
X > 0
       [,1]  [,2]  [,3]  [,4]        [,6]
 [1,]  TRUE FALSE  TRUE FALSE ..... FALSE
 [2,]  TRUE  TRUE  TRUE  TRUE ..... FALSE
 [3,] FALSE  TRUE FALSE  TRUE ..... FALSE
 [4,] FALSE FALSE FALSE  TRUE .....  TRUE
      ..... ..... ..... ..... ..... .....
[10,] FALSE  TRUE  TRUE  TRUE .....  TRUE

rann: chr, pos
cann: group, gender, age
```

```r
X <- X - rowMeans(X)
X
             [,1]        [,2]        [,3]        [,4]                    [,6]
 [1,]  0.84015137 -0.12890112  1.23534833  0.05236833 ........... -0.39410490
 [2,]  0.58625309  1.30953476  0.52311899  0.04950195 ........... -1.79528616
 [3,] -2.32988062  1.62605768  0.14820135  0.63252339 ........... -0.74380675
 [4,]  0.17221049 -0.78967041 -0.71257302  0.83591248 ...........  0.48056599
      ........... ........... ........... ........... ........... ...........
[10,] -1.41900750  0.83995346  0.80112451  0.70255845 ...........  0.48315692

rann: chr, pos
cann: group, gender, age
```

Matrix transpose will preserve the class and correctly adjust row and column annotations.

```r
t(X)
            [,1]        [,2]        [,3]        [,4]                   [,10]
[1,]  0.84015137  0.58625309 -2.32988062  0.17221049 ........... -1.41900750
[2,] -0.12890112  1.30953476  1.62605768 -0.78967041 ...........  0.83995346
[3,]  1.23534833  0.52311899  0.14820135 -0.71257302 ...........  0.80112451
[4,]  0.05236833  0.04950195  0.63252339  0.83591248 ...........  0.70255845
     ........... ........... ........... ........... ........... ...........
[6,] -0.39410490 -1.79528616 -0.74380675  0.48056599 ...........  0.48315692

rann: group, gender, age
cann: chr, pos
```

Principal component analysis with `prcomp` will add row and column annotations to the resulting objects.
Furthermore, matrix cross-product will preserve all annotations that are possible to preserve after the product.
Here is an example where information is carried over after applying PCA rotation to transform a new dataset.

```r
pca <- prcomp(t(X))
pca$rotation
              PC1         PC2         PC3         PC4                     PC6
 [1,]  0.26080230 -0.45332277  0.05027243  0.46904186 ........... -0.48969715
 [2,] -0.05442698 -0.50262139  0.41614222  0.03436835 ...........  0.26831539
 [3,] -0.69297891 -0.16830036 -0.05224952 -0.17119413 ........... -0.55535463
 [4,]  0.07115811  0.26610369 -0.17118495  0.39262010 ...........  0.04176179
      ........... ........... ........... ........... ........... ...........
[10,] -0.23156912 -0.41746097 -0.48222094  0.29355717 ...........  0.38049379

rann: chr, pos
cann: pc, sd, var, var_explained

pca$rotation$var_explained
 [1] 3.918872e-01 2.821670e-01 2.087386e-01 7.917492e-02 3.803232e-02 8.230025e-33

y    <- matrix(rnorm(20), ncol=2)
info <- data.frame(smoker = c(TRUE, FALSE))
Y    <- annmatrix(y, cann = info)

Y_scores <- t(pca$rotation) %*% Y

Y_scores@''
     pc           sd          var var_explained
PC1 PC1 1.930131e+00 3.725405e+00  3.918872e-01
PC2 PC2 1.637794e+00 2.682370e+00  2.821670e-01
PC3 PC3 1.408665e+00 1.984336e+00  2.087386e-01
PC4 PC4 8.675610e-01 7.526621e-01  7.917492e-02
PC5 PC5 6.012881e-01 3.615474e-01  3.803232e-02
PC6 PC6 2.797092e-16 7.823725e-32  8.230025e-33

Y_scores$''
  smoker
1   TRUE
2  FALSE
```


## Technical Details ##

`annmatrix` uses R's S3 class system to extend the base `matrix` class in order to provide it with persistent annotations that are associated with rows and columns.
Technically `annmatrix` object is just a regular R `matrix` with additional `data.frame` attributes `.annmatrix.rann` and `.annmatrix.cann` that are preserved after sub-setting and other matrix-specific operations.
As a result, every function that works on a `matrix` by design should work the same way with `annmatrix`.


## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

