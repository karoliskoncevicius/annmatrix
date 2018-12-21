annmatrix
=========

R Annotated Matrix Object

Description
-----------

The `annmatrix` object tries to implement dimension-aware persistent
metadata for R matrices.

It uses S3 system of R to extend the base `matrix` class in order to
provide it with persistent annotations that are associated with rows and
columns.

The use-case was born out of the need to better organize biomedical
microarray and sequencing data within R. But it is readily applicable in
other contexts where the data can be assembled into a `matrix` form with
rows and columns representing distinct type of information.

Technically `annmatrix` object is just a regular *R* `matrix` with
additional attributes `.annmatrix.rann` and `.annmatrix.cann`. So every
operation that works on a `matrix` by design works in the same way on
`annmatrix`. The only addition `annmatrix` provides is attaching row and
column metadata that are preserved after sub-setting and some helper
functions to use and to change this metadata.

Installation
------------

Using `devtools` library:

`devtools::install_github("KKPWM/annmatrix")`

Usage
-----

Imagine you have a small example of expression data with 25 genes
measured across 10 samples:

    mat <- matrix(rnorm(25*10), nrow=25, ncol=10)

And also some information about genes and samples:

    # sample metadata
    group  <- c(rep("case", 5), rep("control", 5))
    gender <- sample(c("M", "F"), 10, replace=TRUE)

    coldata <- data.frame(group=group, gender=gender, stringsAsFactors=FALSE)

    # row metadata
    chromosome <- sample(c("chr1", "chr2", "chr3"), 25, replace=TRUE)
    position   <- runif(25, 0, 1000000)

    rowdata <- data.frame(chr=chromosome, pos=position, stringsAsFactors=FALSE)

We can then arrange all of this data inside a single `annmatrix` object:

    annMat <- annmatrix(mat, rowdata, coldata)

When printing it shows 5 rows and columns, the total number of rows and
columns and all the metadata available for them:

    annMat

    ##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
    ## [1,]  0.082987 -0.418055 -0.025380 -0.286757  0.570828       ...
    ## [2,]  1.230577 -0.604257 -0.638129 -0.791333 -0.400440       ...
    ## [3,]  0.859493 -0.222388 -0.177819  1.752486 -0.175188       ...
    ## [4,]  0.130358 -1.581395 -1.402617  1.821120 -1.325807       ...
    ## [5,]  0.062373  0.539185 -2.139788  0.883367 -1.823977       ...
    ## [6,]       ...       ...       ...       ...       ...       ...
    ## 
    ## rows:    25 chr, pos
    ## columns: 10 group, gender

The attributes can be accessed with `rann` (for row metadata) and `cann`
(for column metadata):

    rowanns(annMat, "chr")

    ##  [1] "chr1" "chr3" "chr1" "chr1" "chr1" "chr3" "chr1" "chr3" "chr3" "chr2" "chr2" "chr3" "chr2"
    ## [14] "chr3" "chr2" "chr2" "chr3" "chr2" "chr1" "chr3" "chr2" "chr3" "chr3" "chr1" "chr1"

    colanns(annMat, c("group", "gender"))

    ##      group gender
    ## 1     case      F
    ## 2     case      M
    ## 3     case      M
    ## 4     case      M
    ## 5     case      M
    ## 6  control      M
    ## 7  control      F
    ## 8  control      M
    ## 9  control      F
    ## 10 control      F

When the second argument is not provided - entire `data.frame` will be
returned:

    colanns(annMat)

    ##      group gender
    ## 1     case      F
    ## 2     case      M
    ## 3     case      M
    ## 4     case      M
    ## 5     case      M
    ## 6  control      M
    ## 7  control      F
    ## 8  control      M
    ## 9  control      F
    ## 10 control      F

The same functions can also be used to alter the metadata or remove/add
fields to it:

    rowanns(annMat, "chr") <- "chr1"
    rowanns(annMat, "chr")

    ##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
    ## [14] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"

    rowanns(annMat, "strand") <- "+"
    rowanns(annMat, "strand")

    ##  [1] "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+"
    ## [25] "+"

    rowanns(annMat, "strand") <- NULL
    rowanns(annMat, "strand")

    ## NULL

For convenience the operators `@` and `$` are available to select row
and column metadata respectively:

    annMat@chr

    ##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
    ## [14] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"

    annMat$group

    ##  [1] "case"    "case"    "case"    "case"    "case"    "control" "control" "control" "control"
    ## [10] "control"

They also can be used in change the metadata.

    annMat@chr <- "chr2"
    annMat@chr

    ##  [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
    ## [14] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"

When an empty name is provided it will return the whole metadata
`data.frame`:

    annMat$''

    ##      group gender
    ## 1     case      F
    ## 2     case      M
    ## 3     case      M
    ## 4     case      M
    ## 5     case      M
    ## 6  control      M
    ## 7  control      F
    ## 8  control      M
    ## 9  control      F
    ## 10 control      F

When subsetting the `annmatrix` object all the metadata are correctly
adjusted and class is preserved:

    amat <- annMat[1:2,1:3]
    amat

    ##      [,1]      [,2]      [,3]     
    ## [1,]  0.082987 -0.418055 -0.025380
    ## [2,]  1.230577 -0.604257 -0.638129
    ## 
    ## rows:    2 chr, pos
    ## columns: 3 group, gender

    rowanns(amat)

    ##    chr       pos
    ## 1 chr2 551230.56
    ## 2 chr2  28213.13

    colanns(amat)

    ##   group gender
    ## 1  case      F
    ## 2  case      M
    ## 3  case      M

However in order to be consistent with `matrix` the class is dropped
when selecting only a single row or column:

    annMat[1,]

    ##  [1]  0.08298722 -0.41805507 -0.02538036 -0.28675657  0.57082794 -2.31776980  0.79914991 -0.68797316
    ##  [9] -1.23345912 -1.49920017

But just like with `matrix` we can enforce it to preserve all the
annotations and class by setting `drop=FALSE`

    annMat[1,, drop=FALSE]

    ##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
    ## [1,]  0.082987 -0.418055 -0.025380 -0.286757  0.570828       ...
    ## 
    ## rows:    1 chr, pos
    ## columns: 10 group, gender

As an example - to select all the cases and their values on chromosome 2
one would do:

The meta data are also correctly adjusted after transposition
`t(annMat)`.

Operations on `annmatrix` object don't loose the class:

    annMat > 0

    ##      [,1]  [,2]  [,3]  [,4]  [,5]  [,6] 
    ## [1,]  TRUE FALSE FALSE FALSE  TRUE   ...
    ## [2,]  TRUE FALSE FALSE FALSE FALSE   ...
    ## [3,]  TRUE FALSE FALSE  TRUE FALSE   ...
    ## [4,]  TRUE FALSE FALSE  TRUE FALSE   ...
    ## [5,]  TRUE  TRUE FALSE  TRUE FALSE   ...
    ## [6,]   ...   ...   ...   ...   ...   ...
    ## 
    ## rows:    25 chr, pos
    ## columns: 10 group, gender

    annMat <- annMat - rowMeans(annMat)
    annMat

    ##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
    ## [1,]  0.584550  0.083508  0.476183  0.214806  1.072391       ...
    ## [2,]  1.296422 -0.538411 -0.572283 -0.725487 -0.334594       ...
    ## [3,]  0.214465 -0.867417 -0.822847  1.107458 -0.820217       ...
    ## [4,]  0.248989 -1.462764 -1.283987  1.939750 -1.207176       ...
    ## [5,]  0.453435  0.930246 -1.748727  1.274428 -1.432916       ...
    ## [6,]       ...       ...       ...       ...       ...       ...
    ## 
    ## rows:    25 chr, pos
    ## columns: 10 group, gender

`as.matrix` will turn the `annmatrix` object into a `matrix` again and
will drop all it's metadata. Therefore when using `annmatrix` object
within a function the structure in most cases will be lost. This happens
because a lot of functions in R call `as.matrix()` on their arguments.
However we can preserve the class and all the metadata by using `[` for
replacement:

    # scale() looses the class
    class(scale(annMat))

    ## [1] "matrix"

    # in order to preserve - re-assign
    annMat[] <- scale(annMat)
    annMat

    ##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
    ## [1,]  0.66973  0.11736  0.29313  0.38681  1.34428      ...
    ## [2,]  1.51353 -0.72979 -0.81984 -0.52016 -0.23383      ...
    ## [3,]  0.23105 -1.17795 -1.08582  1.24783 -0.77851      ...
    ## [4,]  0.27197 -1.98891 -1.57532  2.05063 -1.21254      ...
    ## [5,]  0.51431  1.27076 -2.06865  1.40888 -1.46573      ...
    ## [6,]      ...      ...      ...      ...      ...      ...
    ## 
    ## rows:    25 chr, pos
    ## columns: 10 group, gender

See Also
--------

Similar ideas can be found in:

1.  [Henrik Bengtsson's "wishlist for
    R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2.  [BioConductor's AnnotatedDataFrame
    object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)
