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
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.930170 -0.073954 -0.567346 -0.980926  0.823666       ...
## [2,] -1.020897  0.641248  0.145145  2.250482  1.808887       ...
## [3,] -0.204803  0.571266  0.497408 -0.919195 -0.047877       ...
## [4,]  0.345671 -0.356812  0.982714  1.343355  1.540517       ...
## [5,]  0.464751 -1.490469 -0.106952 -0.396221  0.723445       ...
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
##  [1] "chr1" "chr1" "chr2" "chr1" "chr2" "chr1" "chr2" "chr3" "chr2" "chr3"
## [11] "chr3" "chr1" "chr3" "chr3" "chr2" "chr1" "chr2" "chr3" "chr1" "chr1"
## [21] "chr2" "chr3" "chr3" "chr2" "chr1"
```

```r
colanns(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      M
## 2     case      M
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      F
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
## 1     case      M
## 2     case      M
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      F
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
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [11] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [21] "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
rowanns(annMat, "strand") <- "+"
rowanns(annMat, "strand")
```

```
##  [1] "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+"
## [18] "+" "+" "+" "+" "+" "+" "+" "+"
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
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [11] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [21] "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
annMat$group
```

```
##  [1] "case"    "case"    "case"    "case"    "case"    "control" "control"
##  [8] "control" "control" "control"
```

They also can be used in change the metadata.


```r
annMat@chr <- "chr2"
annMat@chr
```

```
##  [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
## [11] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
## [21] "chr2" "chr2" "chr2" "chr2" "chr2"
```

When an empty name is provided it will return the whole metadata `data.frame`:


```r
annMat$''
```

```
##      group gender
## 1     case      M
## 2     case      M
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      F
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
## [1,] -0.930170 -0.073954 -0.567346
## [2,] -1.020897  0.641248  0.145145
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr       pos
## 1 chr2  66072.18
## 2 chr2 712810.10
```

```r
colanns(amat)
```

```
##   group gender
## 1  case      M
## 2  case      M
## 3  case      M
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1] -0.93016992 -0.07395378 -0.56734618 -0.98092620  0.82366597
##  [6] -0.20368567  1.36780045 -0.13073898 -1.27712545 -1.07255561
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.930170 -0.073954 -0.567346 -0.980926  0.823666       ...
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
## [1,] FALSE FALSE FALSE FALSE  TRUE   ...
## [2,] FALSE  TRUE  TRUE  TRUE  TRUE   ...
## [3,] FALSE  TRUE  TRUE FALSE FALSE   ...
## [4,]  TRUE FALSE  TRUE  TRUE  TRUE   ...
## [5,]  TRUE FALSE FALSE FALSE  TRUE   ...
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
##      [,1]        [,2]        [,3]        [,4]        [,5]       
## [1,] -0.62566638  0.23054975 -0.26284265 -0.67642267  1.12816951
## [2,] -1.63908356  0.02306125 -0.47304158  1.63229534  1.19070032
## [3,] -0.65866283  0.11740626  0.04354827 -1.37305429 -0.50173627
## [4,] -0.00038377 -0.70286623  0.63665909  0.99730032  1.19446273
## [5,]  0.19689087 -1.75832948 -0.37481251 -0.66408142  0.45558450
## [6,]         ...         ...         ...         ...         ...
##      [,6]       
## [1,]         ...
## [2,]         ...
## [3,]         ...
## [4,]         ...
## [5,]         ...
## [6,]         ...
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
## [1,] -0.542615  0.395283 -0.391635 -0.720364  0.997821       ...
## [2,] -1.939619  0.156077 -0.641287  1.564484  1.060899       ...
## [3,] -0.588101  0.264844 -0.027738 -1.409793 -0.646342       ...
## [4,]  0.319342 -0.680819  0.676695  0.936054  1.064694       ...
## [5,]  0.591286 -1.897625 -0.524621 -0.708150  0.319353       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

