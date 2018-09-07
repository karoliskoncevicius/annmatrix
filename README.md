# annmatrix #

R Annotaded Matrix Object

## Description ##

The *annmatrix* object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base *matrix* class in order to provide it with persistent annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But it is readily applicable in other contexts where the data can be assembled into a matrix form with rows and columns representing distinct type of information.

## Usage ##

Technically *annmatrix* object is just a regular *R* matrix with additional attributes ".annmatrix.rowann" and ".annmatrix.colann".
So every operation that works on a *matrix* by design works in the same way on *annmatrix*.
The only addition *annmatrix* provides is attaching row and column metadata that are preserved after sub-setting and some helper functions to use and to change this metadata.

Imagine we have a small example of expression data with 100 genes measured across 40 samples:

```r
mat <- matrix(rnorm(25*10), nrow=25, ncol=10)
```

And also some information about genes and samples:

```r
# sample annotations
group  <- c(rep("case", 5), rep("control", 5))
gender <- sample(c("M", "F"), 10, replace=TRUE)

coldata <- data.frame(group=group, gender=gender, stringsAsFactors=FALSE)

# row annotations
chromosome <- sample(c("chr1", "chr2", "chr3"), 25, replace=TRUE)
position   <- runif(25, 0, 1000000)

rowdata <- data.frame(chr=chromosome, pos=position, stringsAsFactors=FALSE)


# annmatrix object
library(annmatrix)
annMat <- annmatrix(mat, rowdata, coldata)
```

When printing it shows 5 rows and columns, the total number of rows and columns and all the metadata available for them:

```
> annMat
     [,1]      [,2]      [,3]      [,4]      [,5]      [,6]
[1,]  0.890275 -0.400372 -0.688532 -0.580239 -1.088893       ...
[2,]  0.300604 -0.011946  1.629424 -0.338967  1.337206       ...
[3,] -0.609954 -1.088419  1.314340 -0.271007 -0.877729       ...
[4,]  0.999142 -0.472251  0.507093  0.792640 -0.591627       ...
[5,]  0.776209  0.126976  0.456343  1.790449 -1.189061       ...
[6,]       ...       ...       ...       ...       ...       ...

rows:    25 chr, pos
columns: 10 group, gender
```

The attributes can be accessed through `@` (for row metadata) and `$` (for column metadata)

```
> annMat@chr
 [1] "chr3" "chr3" "chr2" "chr2" "chr1" "chr2" "chr2" "chr1" "chr1" "chr3" "chr1" "chr3" "chr3" "chr1" "chr1" "chr2" "chr1" "chr1" "chr3" "chr2" "chr1" "chr1" "chr1" "chr3" "chr2"

> annMat$group
 [1] "case"    "case"    "case"    "case"    "case"    "control" "control" "control" "control" "control"
```

These are preserved after subsetting:

```r
amat <- annMat[1:2,1:5]
```

```
> amat
     [,1]      [,2]      [,3]      [,4]      [,5]
[1,]  0.890275 -0.400372 -0.688532 -0.580239 -1.088893
[2,]  0.300604 -0.011946  1.629424 -0.338967  1.337206

rows:    2 chr, pos
columns: 5 group, gender

> amat@chr
[1] chr3 chr3

> amat$group
[1] case case case case case
```

Except when selecting only a single row or column (in order to be consistent with *matrix*)

```
> annMat[1,1:10]
[1]  0.8902753 -0.4003718 -0.6885316 -0.5802391 -1.0888930 -0.2200916 -0.3266357  0.2753813 -0.5720766 -0.4183719
```

But just like with *matrix* we can enforce it to preserve all the annotations and class by setting `drop=FALSE`

```
> annMat[1,1:10, drop=FALSE]
     [,1]     [,2]     [,3]     [,4]     [,5]     [,6]
[1,]  0.89028 -0.40037 -0.68853 -0.58024 -1.08889      ...

rows:    1 chr, pos
columns: 10 group, gender
```

As an example - to select all the cases and their values on chromosome 1 we would do:

```r
casechr1 <- annMat[annMat@chr=="chr1", annMat$group=="case"]
```

```
> dim(casechr1)
[1] 11 5
> casechr1@chr
 [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
> casechr1$group
[1] "case" "case" "case" "case" "case"
```

The meta data are also correctly adjusted after transposition `t(annMat)`.

In order to change or add new metadata the functions `$<-` and `@<-` were implemented:

```r
annMat@insideGene <- sample(c(TRUE, FALSE), 25, replace=TRUE)
```

```
> annMat@insideGene
 [1]  TRUE FALSE FALSE FALSE  TRUE  TRUE FALSE FALSE FALSE FALSE  TRUE  TRUE FALSE  TRUE  TRUE FALSE FALSE FALSE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE
```

```r
annMat$age <- runif(10, 20, 100)
```

```
> annMat$age
 [1] 64.81127 92.89155 22.56060 92.55872 97.25848 24.77734 66.93904 58.09345 35.89132 85.40440
```

And in order to access the entire metadata `data.frame` the shortcuts of `$.` and `@.` are provided.

```
> head(annMat@.)
   chr      pos insideGene
1 chr3 340922.4       TRUE
2 chr3 514709.4      FALSE
3 chr2 389955.8      FALSE
4 chr2 727702.3      FALSE
5 chr1 424868.7       TRUE
6 chr2 299012.2       TRUE

> head(annMat$.)
    group gender      age
1    case      F 64.81127
2    case      M 92.89155
3    case      M 22.56060
4    case      M 92.55872
5    case      F 97.25848
6 control      F 24.77734
```

So to change the entire row or column metadata `data.frame` we can use:

```r
annMat@. <- data.frame(ID=1:25, gene=sample(LETTERS, 25, replace=TRUE))
```

```
> head(annMat@.)
  ID gene
1  1    Q
2  2    A
3  3    H
4  4    B
5  5    Y
6  6    H
```

```r
annMat$. <- data.frame(ID=1:10, weight=runif(10, 50, 150))
```

```
> head(annMat$.)
  ID    weight
1  1 113.52080
2  2  78.34452
3  3  88.24793
4  4  52.00214
5  5  75.24068
6  6 117.52739
```

And to delete row or column metadata simply set it to NULL:

```r
annMat@ID <- NULL
```

```
annMat@ID
NULL
```

When operations on *annmatrix* object involve functions that don't loose the class, the result is a proper *annmatrix* object:

```
> scale(annMat)
     [,1]       [,2]       [,3]       [,4]       [,5]       [,6]
[1,]  1.0629881 -0.5076425 -0.4604707 -0.6699645 -1.0362031        ...
[2,]  0.4397408 -0.0078033  1.7386978 -0.4026870  1.5841398        ...
[3,] -0.5226653 -1.3930432  1.4397612 -0.3274025 -0.8081328        ...
[4,]  1.1780541 -0.6001389  0.6738821  0.8508873 -0.4991242        ...
[5,]  0.9424271  0.1709652  0.6257331  1.9562431 -1.1443907        ...
[6,]        ...        ...        ...        ...        ...        ...

rows:    25 gene
columns: 10 ID, weight
```

But sometimes those will be lost - i.e. when doing `apply` on each column:

```r
mat <- apply(annMat, 2, cumsum)
```

```
class(mat)
[1] "matrix"
```

In such a case we can preserve the class and all the metadata by changing the matrix instead of the entire variable via `[<-`:

```r
annMat[] <- apply(annMat, 2, cumsum)
```

```
class(annMat)
[1] "annmatrix" "matrix"
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://bioconductor.org/packages/devel/bioc/manuals/Biobase/man/Biobase.pdf)

