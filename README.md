# annmatrix #

R Annotated Matrix Object

## Description ##

The `annmatrix` object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base `matrix` class in order to provide it with persistent annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But it is readily applicable in other contexts where the data can be assembled into a `matrix` form with rows and columns representing distinct type of information.

Technically `annmatrix` object is just a regular *R* `matrix` with additional attributes `.annmatrix.rann` and `.annmatrix.cann`.
So every operation that works on a `matrix` by design works in the same way on `annmatrix`.
The only addition `annmatrix` provides is attaching row and column metadata that are preserved after sub-setting and some helper functions to use and to change this metadata.

## Usage ##



Imagine you have a small example of expression data with 25 genes measured across 10 samples:


```r
mat <- matrix(rnorm(25*10), nrow=25, ncol=10)
```

And also some information about genes and samples:


```r
# sample metadata
group  <- c(rep("case", 5), rep("control", 5))
gender <- sample(c("M", "F"), 10, replace=TRUE)

coldata <- data.frame(group=group, gender=gender, stringsAsFactors=FALSE)

# row metadata
chromosome <- sample(c("chr1", "chr2", "chr3"), 25, replace=TRUE)
position   <- runif(25, 0, 1000000)

rowdata <- data.frame(chr=chromosome, pos=position, stringsAsFactors=FALSE)
```

We can then arrange all of this data inside a single `annmatrix` object:


```r
annMat <- annmatrix(mat, rowdata, coldata)
```

When printing it shows 5 rows and columns, the total number of rows and columns and all the metadata available for them:


```r
annMat
```

```
##      [,1]       [,2]       [,3]       [,4]       [,5]       [,6]      
## [1,]  0.0058021  0.9736501  0.0489562  0.2204969  0.2673692        ...
## [2,]  2.1958112  0.8077657  1.5353366 -0.0508850  0.1300373        ...
## [3,]  1.4011023 -1.4728889  0.8913339  0.6931578  0.6490379        ...
## [4,] -1.7597532 -1.3327632 -0.0554488  0.6746881  0.1510575        ...
## [5,] -1.4243456 -1.0042674  1.3901938  0.6672661  0.1696845        ...
## [6,]        ...        ...        ...        ...        ...        ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

The attributes can be accessed with `rann` (for row metadata) and `cann` (for column metadata):


```r
rowanns(annMat, "chr")
```

```
##  [1] "chr2" "chr2" "chr3" "chr1" "chr1" "chr2" "chr2" "chr2" "chr1" "chr3" "chr3" "chr1" "chr2" "chr1" "chr1" "chr3"
## [17] "chr1" "chr2" "chr2" "chr2" "chr1" "chr3" "chr1" "chr1" "chr3"
```

```r
colanns(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      M
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      F
## 9  control      M
## 10 control      M
```

When the second argument is not provided - entire `data.frame` will be returned:


```r
colanns(annMat)
```

```
##      group gender
## 1     case      M
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      F
## 9  control      M
## 10 control      M
```

The same functions can also be used to alter the metadata or remove/add fields to it:


```r
rowanns(annMat, "chr") <- "chr1"
rowanns(annMat, "chr")
```

```
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [17] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
rowanns(annMat, "strand") <- "+"
rowanns(annMat, "strand")
```

```
##  [1] "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+"
```

```r
rowanns(annMat, "strand") <- NULL
rowanns(annMat, "strand")
```

```
## NULL
```

For convenience the operators `@` and `$` are available to select row and column metadata respectively:


```r
annMat@chr
```

```
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [17] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
annMat$group
```

```
##  [1] "case"    "case"    "case"    "case"    "case"    "control" "control" "control" "control" "control"
```

They also can be used in change the metadata.


```r
annMat@chr <- "chr2"
annMat@chr
```

```
##  [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
## [17] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
```

When an empty name is provided it will return the whole metadata `data.frame`:


```r
annMat$''
```

```
##      group gender
## 1     case      M
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      F
## 9  control      M
## 10 control      M
```

When subsetting the `annmatrix` object all the metadata are correctly adjusted and class is preserved:


```r
amat <- annMat[1:2,1:3]
amat
```

```
##      [,1]      [,2]      [,3]     
## [1,] 0.0058021 0.9736501 0.0489562
## [2,] 2.1958112 0.8077657 1.5353366
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr      pos
## 1 chr2 503739.4
## 2 chr2 677938.1
```

```r
colanns(amat)
```

```
##   group gender
## 1  case      M
## 2  case      M
## 3  case      F
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1]  0.005802088  0.973650142  0.048956238  0.220496945  0.267369187  0.304145400 -0.931382363 -1.052840072
##  [9]  1.015647681  0.463442329
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] 0.0058021 0.9736501 0.0489562 0.2204969 0.2673692       ...
## 
## rows:    1 chr, pos
## columns: 10 group, gender
```

As an example - to select all the cases and their values on chromosome 1 one would do:



The meta data are also correctly adjusted after transposition `t(annMat)`.

Operations on `annmatrix` object don't loose the class:


```r
annMat > 0
```

```
##      [,1]  [,2]  [,3]  [,4]  [,5]  [,6] 
## [1,]  TRUE  TRUE  TRUE  TRUE  TRUE   ...
## [2,]  TRUE  TRUE  TRUE FALSE  TRUE   ...
## [3,]  TRUE FALSE  TRUE  TRUE  TRUE   ...
## [4,] FALSE FALSE FALSE  TRUE  TRUE   ...
## [5,] FALSE FALSE  TRUE  TRUE  TRUE   ...
## [6,]   ...   ...   ...   ...   ...   ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

```r
annMat <- annMat - rowMeans(annMat)
annMat
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.125727  0.842121 -0.082573  0.088968  0.135840       ...
## [2,]  1.462452  0.074407  0.801978 -0.784244 -0.603322       ...
## [3,]  1.191872 -1.682119  0.682103  0.483927  0.439807       ...
## [4,] -1.184715 -0.757725  0.519590  1.249727  0.726096       ...
## [5,] -1.701217 -1.281139  1.113322  0.390395 -0.107187       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

`as.matrix` will turn the `annmatrix` object into a `matrix` again and will drop all it's metadata.
Therefore when using `annmatrix` object within a function the structure in most cases will be lost.
This happens because a lot of functions in R call `as.matrix()` on their arguments.
However we can preserve the class and all the metadata by using `[` for replacement:


```r
# scale() looses the class
class(scale(annMat))
```

```
## [1] "matrix"
```

```r
# in order to preserve - re-assign
annMat[] <- scale(annMat)
annMat
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.076517  0.989709 -0.290214  0.232703  0.166045       ...
## [2,]  1.770210  0.241450  0.685320 -0.970434 -0.560756       ...
## [3,]  1.455581 -1.470561  0.553116  0.776889  0.464929       ...
## [4,] -1.307903 -0.569593  0.373886  1.832030  0.746429       ...
## [5,] -1.908490 -1.079742  1.028690  0.648018 -0.072918       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

