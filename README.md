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
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,]  0.739497 -0.316374  0.196818 -0.739987 -0.247615       ...
## [2,] -0.221345 -0.111172  2.047719 -0.051771  0.303584       ...
## [3,]  0.671487 -1.312505 -1.123611  0.250716  0.327208       ...
## [4,] -2.211570  0.338192 -0.945152  1.560530 -2.106882       ...
## [5,]  0.457414 -0.268713 -1.166608  0.277060  1.016980       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

The attributes can be accessed with `rowann` (for row metadata) and `colann` (for column metadata):


```r
rowann(annMat, "chr")
```

```
##  [1] "chr3" "chr1" "chr1" "chr2" "chr3" "chr1" "chr3" "chr1" "chr1" "chr2"
## [11] "chr1" "chr2" "chr2" "chr2" "chr1" "chr3" "chr1" "chr1" "chr2" "chr1"
## [21] "chr2" "chr2" "chr2" "chr1" "chr1"
```

```r
colann(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      M
## 2     case      F
## 3     case      F
## 4     case      F
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      F
## 9  control      F
## 10 control      F
```

When the second argument is not provided - entire `data.frame` will be returned:


```r
colann(annMat)
```

```
##      group gender
## 1     case      M
## 2     case      F
## 3     case      F
## 4     case      F
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      F
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
## 1     case      M
## 2     case      F
## 3     case      F
## 4     case      F
## 5     case      M
## 6  control      M
## 7  control      M
## 8  control      F
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
## [1,]  0.73950 -0.31637  0.19682
## [2,] -0.22134 -0.11117  2.04772
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowann(amat)
```

```
##    chr      pos
## 1 chr2 771126.5
## 2 chr2  48200.8
```

```r
colann(amat)
```

```
##   group gender
## 1  case      M
## 2  case      F
## 3  case      F
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1]  0.7394972 -0.3163743  0.1968183 -0.7399870 -0.2476151  0.5961020
##  [7]  1.4043347 -1.2165675 -0.8343318  2.3796253
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,]  0.73950 -0.31637  0.19682 -0.73999 -0.24762      ...
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
## [1,]  TRUE FALSE  TRUE FALSE FALSE   ...
## [2,] FALSE FALSE  TRUE FALSE  TRUE   ...
## [3,]  TRUE FALSE FALSE  TRUE  TRUE   ...
## [4,] FALSE  TRUE FALSE  TRUE FALSE   ...
## [5,]  TRUE FALSE FALSE  TRUE  TRUE   ...
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
## [1,]  0.54334701 -0.51252448  0.00066809 -0.93613718 -0.44376527
## [2,] -0.37494486 -0.26477229  1.89411940 -0.20537123  0.14998349
## [3,]  1.10039787 -0.88359480 -0.69470078  0.67962675  0.75611879
## [4,] -1.35901321  1.19074929 -0.09259462  2.41308697 -1.25432483
## [5,]  0.23055337 -0.49557361 -1.39346768  0.05019978  0.79011995
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
## [1,]  0.607275 -0.256270  0.045195 -0.945229 -0.645680       ...
## [2,] -0.420922  0.059986  2.243701 -0.184457  0.108116       ...
## [3,]  1.230996 -0.729941 -0.762205  0.736880  0.877638       ...
## [4,] -1.522768  1.917961 -0.063093  2.541519 -1.674729       ...
## [5,]  0.257045 -0.234632 -1.573551  0.081608  0.920804       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://bioconductor.org/packages/devel/bioc/manuals/Biobase/man/Biobase.pdf)

A connection with                      
description "stdout"  
class       "terminal"
mode        "w"       
text        "text"    
opened      "opened"  
can read    "no"      
can write   "yes"     
