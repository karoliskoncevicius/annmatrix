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
## [1,] -0.164455  0.022928  0.134618 -0.700237 -0.909821       ...
## [2,] -0.528041 -0.095865 -2.112730 -2.965206  0.276316       ...
## [3,] -0.147430 -0.176805  1.444041  0.046308  0.921337       ...
## [4,] -0.239793  0.416520  2.246258  0.118137  0.192765       ...
## [5,] -0.901759 -0.907739 -1.383355 -0.883386 -1.807295       ...
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
##  [1] "chr1" "chr1" "chr2" "chr1" "chr2" "chr1" "chr1" "chr2" "chr2" "chr2" "chr3" "chr3" "chr2"
## [14] "chr1" "chr1" "chr3" "chr2" "chr1" "chr3" "chr3" "chr1" "chr2" "chr2" "chr2" "chr2"
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
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      M
## 10 control      F
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
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      M
## 10 control      F
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
## 1     case      M
## 2     case      M
## 3     case      F
## 4     case      F
## 5     case      F
## 6  control      F
## 7  control      M
## 8  control      M
## 9  control      M
## 10 control      F
```

When subsetting the `annmatrix` object all the metadata are correctly adjusted and class is preserved:


```r
amat <- annMat[1:2,1:3]
amat
```

```
##      [,1]      [,2]      [,3]     
## [1,] -0.164455  0.022928  0.134618
## [2,] -0.528041 -0.095865 -2.112730
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr      pos
## 1 chr2 551352.5
## 2 chr2 733536.0
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
##  [1] -0.16445454  0.02292837  0.13461838 -0.70023704 -0.90982076 -0.44028929 -0.39524514  0.81102698
##  [9] -0.33360032  0.69062679
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.164455  0.022928  0.134618 -0.700237 -0.909821       ...
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
## [1,] FALSE  TRUE  TRUE FALSE FALSE   ...
## [2,] FALSE FALSE FALSE FALSE  TRUE   ...
## [3,] FALSE FALSE  TRUE  TRUE  TRUE   ...
## [4,] FALSE  TRUE  TRUE  TRUE  TRUE   ...
## [5,] FALSE FALSE FALSE FALSE FALSE   ...
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
## [1,] -0.036010  0.151373  0.263063 -0.571792 -0.781376       ...
## [2,]  0.169437  0.601614 -1.415251 -2.267727  0.973794       ...
## [3,] -0.466735 -0.496109  1.124736 -0.272997  0.602032       ...
## [4,] -0.717212 -0.060899  1.768839 -0.359282 -0.284655       ...
## [5,] -0.355456 -0.361437 -0.837052 -0.337083 -1.260992       ...
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
## [1,]  0.100056  0.117370  0.081736 -0.483201 -1.165991       ...
## [2,]  0.322914  0.650283 -1.299882 -2.753068  1.009318       ...
## [3,] -0.367170 -0.649003  0.791081 -0.083288  0.548566       ...
## [4,] -0.638874 -0.133880  1.321317 -0.198774 -0.550369       ...
## [5,] -0.246462 -0.489601 -0.823898 -0.169061 -1.760413       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

