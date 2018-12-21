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

## Installation ##

Using `devtools` library:

`devtools::install_github("KKPMW/annmatrix")`

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
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,]  1.129127  0.186222  0.135926 -1.643235 -0.062387       ...
## [2,]  0.043306  1.229182 -1.728610  1.552950  1.351227       ...
## [3,]  0.212287  0.936532 -0.077224 -1.612147  0.603509       ...
## [4,]  0.123369  1.825294  0.610138 -1.916757  0.162795       ...
## [5,]  0.584265 -0.323781  1.756105  0.053521 -0.641604       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

The attributes can be accessed with `rann` (for row metadata) and `cann` (for column metadata):


```r
rowanns(annMat, "chr")
```

```
##  [1] "chr3" "chr3" "chr3" "chr2" "chr3" "chr1" "chr3" "chr1" "chr3" "chr1" "chr3" "chr1" "chr1"
## [14] "chr3" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr1" "chr1" "chr3" "chr1" "chr2"
```

```r
colanns(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      F
## 4     case      M
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      F
## 9  control      F
## 10 control      M
```

When the second argument is not provided - entire `data.frame` will be returned:


```r
colanns(annMat)
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      F
## 4     case      M
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      F
## 9  control      F
## 10 control      M
```

The same functions can also be used to alter the metadata or remove/add fields to it:


```r
rowanns(annMat, "chr") <- "chr1"
rowanns(annMat, "chr")
```

```
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [14] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
rowanns(annMat, "strand") <- "+"
rowanns(annMat, "strand")
```

```
##  [1] "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+"
## [25] "+"
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
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [14] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
annMat$group
```

```
##  [1] "case"    "case"    "case"    "case"    "case"    "control" "control" "control" "control"
## [10] "control"
```

They also can be used in change the metadata.


```r
annMat@chr <- "chr2"
annMat@chr
```

```
##  [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
## [14] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
```

When an empty name is provided it will return the whole metadata `data.frame`:


```r
annMat$''
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      F
## 4     case      M
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      F
## 9  control      F
## 10 control      M
```

When subsetting the `annmatrix` object all the metadata are correctly adjusted and class is preserved:


```r
amat <- annMat[1:2,1:3]
amat
```

```
##      [,1]      [,2]      [,3]     
## [1,]  1.129127  0.186222  0.135926
## [2,]  0.043306  1.229182 -1.728610
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr      pos
## 1 chr2 997460.1
## 2 chr2 773943.7
```

```r
colanns(amat)
```

```
##   group gender
## 1  case      F
## 2  case      F
## 3  case      F
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1]  1.12912725  0.18622171  0.13592558 -1.64323467 -0.06238711 -0.68400126 -0.19800254 -1.73957675
##  [9] -1.21199972 -1.90221542
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,]  1.129127  0.186222  0.135926 -1.643235 -0.062387       ...
## 
## rows:    1 chr, pos
## columns: 10 group, gender
```

As an example - to select all the cases and their values on chromosome 2 one would do:



The meta data are also correctly adjusted after transposition `t(annMat)`.

Operations on `annmatrix` object don't loose the class:


```r
annMat > 0
```

```
##      [,1]  [,2]  [,3]  [,4]  [,5]  [,6] 
## [1,]  TRUE  TRUE  TRUE FALSE FALSE   ...
## [2,]  TRUE  TRUE FALSE  TRUE  TRUE   ...
## [3,]  TRUE  TRUE FALSE FALSE  TRUE   ...
## [4,]  TRUE  TRUE  TRUE FALSE  TRUE   ...
## [5,]  TRUE FALSE  TRUE  TRUE FALSE   ...
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
## [1,]  1.728142  0.785236  0.734940 -1.044220  0.536627       ...
## [2,]  0.105376  1.291253 -1.666539  1.615020  1.413298       ...
## [3,]  0.025853  0.750099 -0.263657 -1.798580  0.417075       ...
## [4,] -0.003085  1.698840  0.483684 -2.043210  0.036342       ...
## [5,]  0.397529 -0.510517  1.569369 -0.133215 -0.828340       ...
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
## [1,]  1.779032  0.977275  1.081681 -0.936408  0.170845       ...
## [2,]  0.018796  1.479531 -1.698952  1.381487  1.084952       ...
## [3,] -0.067464  0.942398 -0.074578 -1.593937  0.046187       ...
## [4,] -0.098854  1.884090  0.790756 -1.807166 -0.350805       ...
## [5,]  0.335698 -0.308851  2.047853 -0.142341 -1.252412       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

