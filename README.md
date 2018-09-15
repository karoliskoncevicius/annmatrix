# annmatrix #

R Annotated Matrix Object

## Description ##

The `annmatrix` object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base `matrix` class in order to provide it with persistent annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But it is readily applicable in other contexts where the data can be assembled into a `matrix` form with rows and columns representing distinct type of information.

Technically `annmatrix` object is just a regular *R* `matrix` with additional attributes `.annmatrix.rowann` and `.annmatrix.colann`.
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
## [1,] -0.546478 -0.995943  1.728842  0.789954 -1.493911       ...
## [2,]  1.673162  1.573800 -0.606875 -1.168075 -0.607056       ...
## [3,]  1.876453  0.423539  0.580571  1.145703  0.270331       ...
## [4,]  0.877341 -2.262257  0.089509  0.084198 -0.781048       ...
## [5,] -0.272941  0.783686  0.035691 -1.131001 -1.039066       ...
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
##  [1] "chr1" "chr3" "chr2" "chr2" "chr2" "chr1" "chr2" "chr2" "chr3" "chr1"
## [11] "chr2" "chr2" "chr2" "chr1" "chr3" "chr3" "chr1" "chr1" "chr1" "chr3"
## [21] "chr1" "chr1" "chr2" "chr3" "chr1"
```

```r
colann(annMat, c("group", "gender"))
```

```
##      group gender
## 1     case      M
## 2     case      F
## 3     case      F
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      F
## 8  control      F
## 9  control      M
## 10 control      M
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
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      F
## 8  control      F
## 9  control      M
## 10 control      M
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
## 4     case      M
## 5     case      M
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
##      [,1]     [,2]     [,3]    
## [1,] -0.54648 -0.99594  1.72884
## [2,]  1.67316  1.57380 -0.60688
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowann(amat)
```

```
##    chr      pos
## 1 chr2 986579.7
## 2 chr2 559360.8
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
##  [1] -0.54647751 -0.99594299  1.72884173  0.78995390 -1.49391117
##  [6]  1.71404235  0.98198519 -1.02442083  0.02159985  0.14095487
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -0.54648 -0.99594  1.72884  0.78995 -1.49391      ...
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
## [1,] FALSE FALSE  TRUE  TRUE FALSE   ...
## [2,]  TRUE  TRUE FALSE FALSE FALSE   ...
## [3,]  TRUE  TRUE  TRUE  TRUE  TRUE   ...
## [4,]  TRUE FALSE  TRUE  TRUE FALSE   ...
## [5,] FALSE  TRUE  TRUE FALSE FALSE   ...
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
## [1,] -0.678140 -1.127606  1.597179  0.658291 -1.625574       ...
## [2,]  1.287301  1.187939 -0.992737 -1.553936 -0.992917       ...
## [3,]  1.340897 -0.112018  0.045014  0.610147 -0.265226       ...
## [4,]  1.192944 -1.946654  0.405112  0.399800 -0.465446       ...
## [5,]  0.220378  1.277005  0.529009 -0.637683 -0.545747       ...
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
##      [,1]       [,2]       [,3]       [,4]       [,5]       [,6]      
## [1,] -0.6833593 -1.2701960  1.7343465  1.1556021 -1.6589214        ...
## [2,]  1.2299558  1.6320019 -0.9885345 -1.5287015 -0.9738413        ...
## [3,]  1.2821296  0.0026957  0.1024940  1.0971835 -0.1858519        ...
## [4,]  1.1381011 -2.2967542  0.4810789  0.8419507 -0.4026624        ...
## [5,]  0.1913285  1.7436334  0.6113374 -0.4169254 -0.4896177        ...
## [6,]        ...        ...        ...        ...        ...        ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

