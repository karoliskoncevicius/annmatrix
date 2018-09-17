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
## [1,] -0.412852  0.480246 -0.667628 -1.300305 -0.506013       ...
## [2,] -0.848179 -1.650363  0.613437 -0.576292  1.453715       ...
## [3,]  0.119304 -0.915139 -1.861053 -0.535924  0.199388       ...
## [4,]  0.188267 -0.417044  0.136320 -0.922746  0.221261       ...
## [5,]  1.572805  0.588687 -0.629479  0.028843 -1.804262       ...
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
## Error in rowanns(annMat, "chr"): could not find function "rowanns"
```

```r
colanns(annMat, c("group", "gender"))
```

```
## Error in colanns(annMat, c("group", "gender")): could not find function "colanns"
```

When the second argument is not provided - entire `data.frame` will be returned:


```r
colanns(annMat)
```

```
## Error in colanns(annMat): could not find function "colanns"
```

The same functions can also be used to alter the metadata or remove/add fields to it:


```r
rowanns(annMat, "chr") <- "chr1"
```

```
## Error in rowanns(annMat, "chr") <- "chr1": could not find function "rowanns<-"
```

```r
rowanns(annMat, "chr")
```

```
## Error in rowanns(annMat, "chr"): could not find function "rowanns"
```

```r
rowanns(annMat, "strand") <- "+"
```

```
## Error in rowanns(annMat, "strand") <- "+": could not find function "rowanns<-"
```

```r
rowanns(annMat, "strand")
```

```
## Error in rowanns(annMat, "strand"): could not find function "rowanns"
```

```r
rowanns(annMat, "strand") <- NULL
```

```
## Error in rowanns(annMat, "strand") <- NULL: could not find function "rowanns<-"
```

```r
rowanns(annMat, "strand")
```

```
## Error in rowanns(annMat, "strand"): could not find function "rowanns"
```

For convenience the operators `@` and `$` are available to select row and column metadata respectively:


```r
annMat@chr
```

```
##  [1] "chr1" "chr2" "chr3" "chr2" "chr1" "chr2" "chr1" "chr2" "chr2" "chr1"
## [11] "chr2" "chr3" "chr2" "chr2" "chr3" "chr3" "chr1" "chr2" "chr1" "chr1"
## [21] "chr2" "chr1" "chr2" "chr2" "chr3"
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
## 2     case      M
## 3     case      M
## 4     case      M
## 5     case      M
## 6  control      M
## 7  control      F
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
## [1,] -0.41285  0.48025 -0.66763
## [2,] -0.84818 -1.65036  0.61344
## 
## rows:    2 chr, pos
## columns: 3 group, gender
```

```r
rowanns(amat)
```

```
## Error in rowanns(amat): could not find function "rowanns"
```

```r
colanns(amat)
```

```
## Error in colanns(amat): could not find function "colanns"
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column:


```r
annMat[1,]
```

```
##  [1] -0.4128520  0.4802455 -0.6676284 -1.3003053 -0.5060134 -0.5116670
##  [7]  0.8499302  0.3454944 -0.2478704  2.2656775
```

But just like with `matrix` we can enforce it to preserve all the annotations and class by setting `drop=FALSE`


```r
annMat[1,, drop=FALSE]
```

```
##      [,1]     [,2]     [,3]     [,4]     [,5]     [,6]    
## [1,] -0.41285  0.48025 -0.66763 -1.30031 -0.50601      ...
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
## [1,] FALSE  TRUE FALSE FALSE FALSE   ...
## [2,] FALSE FALSE  TRUE FALSE  TRUE   ...
## [3,]  TRUE FALSE FALSE FALSE  TRUE   ...
## [4,]  TRUE FALSE  TRUE FALSE  TRUE   ...
## [5,]  TRUE  TRUE FALSE  TRUE FALSE   ...
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
## [1,] -0.442353  0.450744 -0.697130 -1.329806 -0.535514       ...
## [2,] -0.647063 -1.449248  0.814553 -0.375176  1.654831       ...
## [3,]  0.570807 -0.463636 -1.409550 -0.084421  0.650891       ...
## [4,]  0.112373 -0.492938  0.060427 -0.998639  0.145368       ...
## [5,]  1.425306  0.441189 -0.776977 -0.118656 -1.951761       ...
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
## [1,] -0.5731975  0.4520815 -0.6877762 -1.2831501 -0.3858683        ...
## [2,] -0.7817372 -2.0505052  1.1356244 -0.2971653  1.6123199        ...
## [3,]  0.4589179 -0.7523002 -1.5471025  0.0031392  0.6964547        ...
## [4,] -0.0080929 -0.7908960  0.2259925 -0.9411061  0.2352808        ...
## [5,]  1.3294037  0.4394954 -0.7840890 -0.0322195 -1.6778686        ...
## [6,]        ...        ...        ...        ...        ...        ...
## 
## rows:    25 chr, pos
## columns: 10 group, gender
```

## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

