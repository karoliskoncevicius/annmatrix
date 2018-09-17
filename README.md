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
## [1,] -1.460870 -0.094723 -0.459316  0.423635 -0.908035       ...
## [2,]  0.457633 -2.439557  2.038390  0.413780 -0.031605       ...
## [3,]  0.567247  0.318441  0.868275 -1.281060  0.577446       ...
## [4,] -1.178497  1.511205 -0.945380 -1.364283 -1.156390       ...
## [5,] -2.014972 -0.569157 -0.512141  0.768336 -1.432570       ...
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
##  [1] "chr1" "chr3" "chr1" "chr2" "chr1" "chr1" "chr1" "chr1" "chr1" "chr2" "chr2" "chr3" "chr1" "chr1" "chr3"
## [16] "chr2" "chr2" "chr2" "chr2" "chr1" "chr2" "chr3" "chr2" "chr2" "chr1"
```

```r
colanns(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      M
## 2     case      F
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      M
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
## 2     case      F
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      M
## 9  control      M
## 10 control      M
```

The same functions can also be used to alter the metadata or remove/add fields to it:


```r
rowanns(annMat, "chr") <- "chr1"
rowanns(annMat, "chr")
```

```
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [16] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
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
##  [1] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
## [16] "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1" "chr1"
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
##  [1] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
## [16] "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2" "chr2"
```

When an empty name is provided it will return the whole metadata `data.frame`:


```r
annMat$''
```

```
##      group gender
## 1     case      M
## 2     case      F
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      M
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
## [1,] -1.460870 -0.094723 -0.459316
## [2,]  0.457633 -2.439557  2.038390
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
##    chr      pos
## 1 chr2 711874.2
## 2 chr2 347885.1
```

```r
colanns(amat)
```

```
##   group gender
## 1  case      M
## 2  case      F
## 3  case      M
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1] -1.46086966 -0.09472295 -0.45931587  0.42363502 -0.90803484  0.92115314 -0.40705251 -0.20498454
##  [9] -0.08012871 -0.84596316
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -1.460870 -0.094723 -0.459316  0.423635 -0.908035       ...
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
## [1,] FALSE FALSE FALSE  TRUE FALSE   ...
## [2,]  TRUE FALSE  TRUE  TRUE FALSE   ...
## [3,]  TRUE  TRUE  TRUE FALSE  TRUE   ...
## [4,] FALSE  TRUE FALSE FALSE FALSE   ...
## [5,] FALSE FALSE FALSE  TRUE FALSE   ...
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
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -1.14924  0.21691 -0.14769  0.73526 -0.59641      ...
## [2,]  0.16912 -2.72807  1.74988  0.12527 -0.32012      ...
## [3,]  0.71792  0.46911  1.01895 -1.13039  0.72812      ...
## [4,] -0.78444  1.90526 -0.55132 -0.97022 -0.76233      ...
## [5,] -1.66020 -0.21438 -0.15736  1.12311 -1.07779      ...
## [6,]      ...      ...      ...      ...      ...      ...
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
##      [,1]       [,2]       [,3]       [,4]       [,5]       [,6]      
## [1,] -1.0093011  0.3571585 -0.2603825  0.6917811 -0.5335282        ...
## [2,]  0.2303162 -2.7193441  1.4940477 -0.0051291 -0.1508837        ...
## [3,]  0.7463327  0.6206307  0.8182510 -1.4396989  1.3008495        ...
## [4,] -0.6662882  2.1209230 -0.6335693 -1.2567141 -0.7633222        ...
## [5,] -1.4897362 -0.0933903 -0.2693297  1.1348930 -1.2002174        ...
## [6,]        ...        ...        ...        ...        ...        ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

