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

`devtools::install_github("KKPWM/annmatrix")`

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
## [1,] -0.085367  1.841969  0.125285  2.207039  1.925318       ...
## [2,] -0.044398  1.384137  0.476496 -1.275680 -0.936873       ...
## [3,] -0.917512 -1.619758  0.338843  1.067277 -1.647326       ...
## [4,] -0.681122 -0.304784 -2.216567 -1.036474 -0.119566       ...
## [5,] -1.108362 -1.322911 -1.691756  0.575496  2.114062       ...
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
##  [1] "chr2" "chr2" "chr3" "chr3" "chr1" "chr1" "chr3" "chr2" "chr1" "chr3" "chr2" "chr3" "chr1"
## [14] "chr1" "chr2" "chr3" "chr3" "chr2" "chr2" "chr1" "chr1" "chr2" "chr2" "chr3" "chr1"
```

```r
colanns(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      F
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      M
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
## 1     case      F
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      M
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
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      M
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
## [1,] -0.085367  1.841969  0.125285
## [2,] -0.044398  1.384137  0.476496
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr       pos
## 1 chr2  81598.04
## 2 chr2 317084.06
```

```r
colanns(amat)
```

```
##   group gender
## 1  case      F
## 2  case      M
## 3  case      F
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1] -0.08536681  1.84196889  0.12528477  2.20703892  1.92531798  0.64210349 -0.76858078  0.30503045
##  [9] -0.79562561 -1.36755884
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.085367  1.841969  0.125285  2.207039  1.925318       ...
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
## [1,] FALSE  TRUE  TRUE  TRUE  TRUE   ...
## [2,] FALSE  TRUE  TRUE FALSE FALSE   ...
## [3,] FALSE FALSE  TRUE  TRUE FALSE   ...
## [4,] FALSE FALSE FALSE FALSE FALSE   ...
## [5,] FALSE FALSE FALSE  TRUE  TRUE   ...
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
## [1,] -0.488328  1.439008 -0.277676  1.804078  1.522357       ...
## [2,] -0.081591  1.346944  0.439303 -1.312873 -0.974066       ...
## [3,] -0.757328 -1.459574  0.499027  1.227461 -1.487142       ...
## [4,] -0.417551 -0.041213 -1.952996 -0.772903  0.144005       ...
## [5,] -0.616288 -0.830838 -1.199683  1.067569  2.606135       ...
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
## [1,] -0.215214  1.610876 -0.360565  1.571275  1.189674       ...
## [2,]  0.154662  1.525579  0.380753 -1.470602 -0.908483       ...
## [3,] -0.459835 -1.074643  0.442505  1.008547 -1.339705       ...
## [4,] -0.150851  0.239460 -2.092754 -0.943637  0.031218       ...
## [5,] -0.331578 -0.492122 -1.313869  0.852506  2.100552       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)
