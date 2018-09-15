# annmatrix #

R Annotaded Matrix Object

## Description ##

The *annmatrix* object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base *matrix* class in order to provide it with persistent annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But it is readily applicable in other contexts where the data can be assembled into a matrix form with rows and columns representing distinct type of information.

Technically *annmatrix* object is just a regular *R* matrix with additional attributes ".annmatrix.rowann" and ".annmatrix.colann".
So every operation that works on a *matrix* by design works in the same way on *annmatrix*.
The only addition *annmatrix* provides is attaching row and column metadata that are preserved after sub-setting and some helper functions to use and to change this metadata.

## Usage ##

Imagine you have a small example of expression data with 25 genes measured across 10 samples:


```r
mat <- matrix(rnorm(ng*ns), nrow=ng, ncol=ns)
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
library(annmatrix)
```

```
## 
## Attaching package: 'annmatrix'
```

```
## The following objects are masked from 'package:base':
## 
##     @, @<-
```

```r
annMat <- annmatrix(mat, rowdata, coldata)
```

When printing it shows 5 rows and columns, the total number of rows and columns and all the metadata available for them:


```r
annMat
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.839369 -1.352969 -0.055759 -1.369458  0.705980       ...
## [2,]  0.328249  0.026202  0.817807  1.183275 -0.337218       ...
## [3,] -0.948891  0.230498  1.063994 -0.039457 -0.980677       ...
## [4,] -0.415267  0.242071 -0.834630 -0.719877  1.574619       ...
## [5,]  1.632019  1.049652  1.298314  0.181100  0.796220       ...
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
##  [1] "chr3" "chr3" "chr1" "chr2" "chr3" "chr3" "chr3" "chr2" "chr3" "chr2"
## [11] "chr2" "chr2" "chr1" "chr2" "chr1" "chr2" "chr2" "chr3" "chr2" "chr3"
## [21] "chr3" "chr1" "chr2" "chr2" "chr2"
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
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      M
## 9  control      M
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
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      M
## 9  control      M
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

For convenience - when an empty name is provided it will return the whole metadata `data.frame`:


```r
annMat$''
```

```
##      group gender
## 1     case      F
## 2     case      F
## 3     case      M
## 4     case      F
## 5     case      F
## 6  control      M
## 7  control      F
## 8  control      M
## 9  control      M
## 10 control      F
```

All the arguments are correctly adjusted after subsetting:


```r
amat <- annMat[1:2,1:3]
amat
```

```
##      [,1]      [,2]      [,3]     
## [1,] -0.839369 -1.352969 -0.055759
## [2,]  0.328249  0.026202  0.817807
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowann(amat)
```

```
##    chr       pos
## 1 chr2 156168.03
## 2 chr2  17656.75
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

Except when selecting only a single row or column (in order to be consistent with *matrix*)


```r
annMat[1,]
```

```
##  [1] -0.83936861 -1.35296924 -0.05575941 -1.36945836  0.70598025
##  [6] -1.94016411  1.31827981  1.34954809  0.50695617  1.53791305
```

But just like with *matrix* we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]     
## [1,] -0.839369 -1.352969 -0.055759 -1.369458  0.705980       ...
## 
## rows:    1 chr, pos
## columns: 10 group, gender
```

As an example - to select all the cases and their values on chromosome 1 one would do:



The meta data are also correctly adjusted after transposition `t(annMat)`.

Operations on *annmatrix* object don't loose the class:


```r
annMat > 0
```

```
##      [,1]  [,2]  [,3]  [,4]  [,5]  [,6] 
## [1,] FALSE FALSE FALSE FALSE  TRUE   ...
## [2,]  TRUE  TRUE  TRUE  TRUE FALSE   ...
## [3,] FALSE  TRUE  TRUE FALSE FALSE   ...
## [4,] FALSE  TRUE FALSE FALSE  TRUE   ...
## [5,]  TRUE  TRUE  TRUE  TRUE  TRUE   ...
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
##      [,1]       [,2]       [,3]       [,4]       [,5]       [,6]      
## [1,] -0.8254644 -1.3390650 -0.0418552 -1.3555541  0.7198845        ...
## [2,]  0.2329068 -0.0691400  0.7224642  1.0879322 -0.4325605        ...
## [3,] -0.9009302  0.2784584  1.1119546  0.0085034 -0.9327161        ...
## [4,] -0.3595391  0.2977991 -0.7789020 -0.6641491  1.6303468        ...
## [5,]  1.0775054  0.4951382  0.7438001 -0.3734141  0.2417060        ...
## [6,]        ...        ...        ...        ...        ...        ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

But using annMat within a function the structure in most cases will be lost.
However we can preserve it by using `[` for matrix replacement:


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
## [1,] -0.740650 -1.600314 -0.240639 -1.660621  0.827768       ...
## [2,]  0.404797 -0.174756  0.838920  1.279461 -0.423403       ...
## [3,] -0.822324  0.215441  1.389054 -0.019343 -0.966406       ...
## [4,] -0.236391  0.237152 -1.281677 -0.828700  1.816228       ...
## [5,]  1.318883  0.458675  0.869056 -0.478878  0.308626       ...
## [6,]       ...       ...       ...       ...       ...       ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://bioconductor.org/packages/devel/bioc/manuals/Biobase/man/Biobase.pdf)

