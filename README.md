# annmatrix #

R Annotated Matrix Object

## Description ##

The `annmatrix` object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base *matrix* class in order to provide it with persistent annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But it is readily applicable in other contexts where the data can be assembled into a matrix form with rows and columns representing distinct type of information.

Technically `annmatrix` object is just a regular *R* matrix with additional attributes `.annmatrix.rowann` and `.annmatrix.colann`.
So every operation that works on a *matrix* by design works in the same way on `annmatrix`.
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
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -1.14416  1.43033 -0.87312  0.29974  0.80084      ...
## [2,] -0.13754  0.48740  0.56152 -1.26598  1.24515      ...
## [3,]  0.26834  1.15042 -0.36435  0.29772 -1.48447      ...
## [4,]  0.86574 -1.04754  1.29016 -0.79339  0.45015      ...
## [5,] -1.09794 -0.47505 -0.48652  0.10367  1.15610      ...
## [6,]      ...      ...      ...      ...      ...      ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

The attributes can be accessed with `rowann` (for row metadata) and `colann` (for column metadata):


```r
rowann(annMat, "chr")
```

```
##  [1] "chr1" "chr2" "chr3" "chr3" "chr1" "chr3" "chr2" "chr3" "chr3" "chr2"
## [11] "chr3" "chr2" "chr1" "chr1" "chr1" "chr3" "chr2" "chr1" "chr2" "chr1"
## [21] "chr3" "chr3" "chr1" "chr1" "chr3"
```

```r
colann(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      M
## 4     case      F
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      F
## 10 control      F
```

When the second argument is not provided - entire `data.frame` will be returned:


```r
colann(annMat)
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      M
## 4     case      F
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      F
## 10 control      F
```

The same functions can also be used to alter the metadata or remove/add fields to it:


```r
rowann(annMat, "chr") <- "chr1"
rowann(annMat, "chr")
```

```
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [11] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [21] "chr1" "chr1" "chr1" "chr1" "chr1"
```

```r
rowann(annMat, "strand") <- "+"
rowann(annMat, "strand")
```

```
##  [1] "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+" "+"
## [18] "+" "+" "+" "+" "+" "+" "+" "+"
```

```r
rowann(annMat, "strand") <- NULL
rowann(annMat, "strand")
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
## 1     case      F
## 2     case      F
## 3     case      M
## 4     case      F
## 5     case      M
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      F
## 10 control      F
```

When subsetting the `annmatrix` object all the metadata are correctly adjusted and class is preserved:


```r
amat <- annMat[1:2,1:3]
amat
```

```
##      [,1]     [,2]     [,3]    
## [1,] -1.14416  1.43033 -0.87312
## [2,] -0.13754  0.48740  0.56152
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowann(amat)
```

```
##    chr      pos
## 1 chr2 545801.6
## 2 chr2 934479.3
```

```r
colann(amat)
```

```
##   group gender
## 1  case      F
## 2  case      F
## 3  case      M
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1] -1.1441621  1.4303286 -0.8731225  0.2997429  0.8008371  0.4380678
##  [7]  0.5932692  1.2618104  1.0874959  0.1472184
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -1.14416  1.43033 -0.87312  0.29974  0.80084      ...
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
## [1,] FALSE  TRUE FALSE  TRUE  TRUE   ...
## [2,] FALSE  TRUE  TRUE FALSE  TRUE   ...
## [3,]  TRUE  TRUE FALSE  TRUE FALSE   ...
## [4,]  TRUE FALSE  TRUE FALSE  TRUE   ...
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
## [1,] -1.548311  1.026180 -1.277271 -0.104406  0.396689       ...
## [2,] -0.084606  0.540340  0.614455 -1.213046  1.298087       ...
## [3,]  0.233193  1.115276 -0.399502  0.262575 -1.519618       ...
## [4,]  0.640463 -1.272818  1.064888 -1.018663  0.224875       ...
## [5,] -1.255200 -0.632315 -0.643785 -0.053592  0.998839       ...
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
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -1.61963  0.95815 -1.56679 -0.17913  0.37312      ...
## [2,]  0.20195  0.53527  1.01745 -1.64014  1.38045      ...
## [3,]  0.59745  1.03570 -0.36769  0.30449 -1.76838      ...
## [4,]  1.10429 -1.04296  1.63278 -1.38397  0.18112      ...
## [5,] -1.25485 -0.48544 -0.70140 -0.11217  1.04604      ...
## [6,]      ...      ...      ...      ...      ...      ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://bioconductor.org/packages/devel/bioc/manuals/Biobase/man/Biobase.pdf)

