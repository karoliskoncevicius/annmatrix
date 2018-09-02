# annMatrix #

R Annotaded Matrix Object

## Description ##

The *annMatrix* object tries to implement dimension-aware persistent metadata for R matrices.

It uses S3 system of R to extend the base *matrix* class in order to provide it with persistent
annotations that are associated with rows and columns.

The use-case was born out of the need to better organize biomedical microarray and sequencing
data within R. But it is readily applicable in other contexts where the data can be assembled
into a matrix form with rows and columns representing distinct type of information.

## Usage ##

Technically *annMatrix* object is just a regular *R* matrix with additional attributes "rowAnn" and "colAnn". So
every operation that works on a *matrix* by design works in the same way on *annMatrix*. The only addition
*annMatrix* provides is attaching row and column metadata that are preserved after sub-setting and some helper
functions to use and to change this metadata.

Imagine we have a small example of expression data with 100 genes measured across 40 samples:

```r
mat <- matrix(rnorm(100*40), nrow=100, ncol=40)
```

And also some information about genes and samples:

```r
# sample annotations
group  <- c(rep("case", 20), rep("control", 20))
gender <- sample(c("M", "F"), 40, replace=TRUE)

coldata <- data.frame(group=group, gender=gender)

# row annotations
chromosome <- sample(c("chr1", "chr2", "chr3"), 100, replace=TRUE)
position   <- runif(100, 0, 1000000)

rowdata <- data.frame(chr=chromosome, pos=position)


# annMatrix object
library(annMatrix)
annMat <- annMatrix(mat, rowdata, coldata)
```

When printing it shows 10 rows and columns, the total number of rows and columns
and all the metadata available for them:

```
> annMat
      [,1]      [,2]      [,3]      [,4]      [,5]      [,6]      [,7]      [,8]      [,9]      [,10]     [,11]
 [1,]  0.229642 -0.577436  0.710451 -2.584399  0.144217  0.160170  1.326462  0.280646 -0.523914 -0.067775       ...
 [2,] -0.881161  0.522464 -1.185298 -1.538961  0.777940  0.565999  1.320626  0.305031  1.184184  1.915076       ...
 [3,]  0.778003 -0.071457 -0.524569  0.770265 -0.201659  2.811973  0.087890 -0.344098  1.345689 -2.071811       ...
 [4,]  0.416715  1.368081 -0.033516  0.316980 -0.335119  1.307661  0.877373  0.086436  0.660933 -0.300566       ...
 [5,]  0.569463 -0.464443 -0.964980 -0.566982 -0.478304 -1.514175 -0.800464 -1.112094 -0.058771  1.185985       ...
 [6,] -0.898649 -1.369807 -0.515230  0.100625  1.365621 -0.151956  1.166109 -1.598136  0.278360 -1.005069       ...
 [7,] -1.614568  0.803268  0.988140  0.793850 -1.733140  0.714440  0.486672 -1.674717  0.859909 -2.010129       ...
 [8,] -0.297958  1.695464  0.128436 -0.058953 -0.841190  1.031789 -0.438215 -2.333452 -1.656725 -0.647570       ...
 [9,] -0.237990  1.206582  0.694747 -1.149255  0.962558 -1.600865 -0.786101  1.108816 -1.169713 -2.763090       ...
[10,]  1.079531  0.047240  0.690826 -0.094766  1.034669 -1.455690 -0.163271 -1.189629 -0.391617 -0.124317       ...
[11,]       ...       ...       ...       ...       ...       ...       ...       ...       ...       ...       ...

rows:    100 chr, pos
columns: 40 group, gender

```

The attributes can be accessed through `@` (for row metadata) and `$` (for column metadata)

```
> annMat@chr
  [1] chr2 chr2 chr3 chr2 chr3 chr1 chr2 chr3 chr2 chr3 chr3 chr2 chr3 chr3 chr1
 [16] chr2 chr2 chr1 chr3 chr1 chr3 chr1 chr1 chr3 chr1 chr3 chr3 chr2 chr2 chr3
 [31] chr2 chr3 chr1 chr3 chr3 chr1 chr3 chr1 chr2 chr2 chr3 chr1 chr1 chr1 chr3
 [46] chr2 chr1 chr3 chr3 chr1 chr1 chr3 chr1 chr2 chr3 chr2 chr3 chr1 chr3 chr2
 [61] chr3 chr2 chr2 chr1 chr2 chr2 chr3 chr3 chr2 chr2 chr1 chr3 chr1 chr2 chr3
 [76] chr2 chr2 chr2 chr1 chr3 chr1 chr2 chr2 chr3 chr3 chr2 chr2 chr2 chr2 chr1
 [91] chr3 chr2 chr1 chr2 chr1 chr2 chr1 chr2 chr3 chr2

> annMat$group
 [1] case    case    case    case    case    case    case    case    case
[10] case    case    case    case    case    case    case    case    case
[19] case    case    control control control control control control control
[28] control control control control control control control control control
[37] control control control control
```

These are preserved after subsetting:

```r
amat <- annMat[1:2,1:5]
```

```
> amat
     [,1]     [,2]     [,3]     [,4]     [,5]
[1,]  0.22964 -0.57744  0.71045 -2.58440  0.14422
[2,] -0.88116  0.52246 -1.18530 -1.53896  0.77794

rows:    2 chr, pos
columns: 5 group, gender

> amat@chr
[1] chr2 chr2

> amat$group
[1] case case case case case
```

Except when selecting only a single row or column (in order to be consistent with *matrix*)

```
> annMat[1,1:10]
[1]  0.22964243 -0.57743591  0.71045094 -2.58439900  0.14421724  0.16017038  1.32646186  0.28064587 -0.52391383 -0.06777517
```

But just like with *matrix* we can enforce it to preserve all the annotations and class by setting `drop=FALSE`

```
> annMat[1,1:10, drop=FALSE]
     [,1]      [,2]      [,3]      [,4]      [,5]      [,6]      [,7]      [,8]      [,9]      [,10]
[1,]  0.334981  1.546200  0.304262 -0.234205 -0.176153 -0.027926  0.148826 -1.245349 -0.399667  0.205725

rows:    1 chr, pos
columns: 10 group, gender
```

As an example - to select all the cases and their values on chromosome 1 we would do:

```r
casechr1 <- annMat[annMat@chr=="chr1", annMat$group=="case"]
```

```
> dim(casechr1)
[1] 27 20
> casechr1@chr
 [1] chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1
[16] chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1 chr1
> casechr1@group
 [1] case case case case case case case case case case case case case case case
[16] case case case case case
```

The meta data are also correctly adjusted after transposition `t(annMat)`.

In order to change or add new metadata the functions `$<-` and `@<-` were implemented:

```r
annMat@insideGene <- sample(c(TRUE, FALSE), 100, replace=TRUE)
```

```
> annMat@insideGene
  [1] FALSE FALSE  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE
 [13] FALSE FALSE  TRUE FALSE FALSE  TRUE  TRUE  TRUE FALSE  TRUE  TRUE FALSE
 [25] FALSE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE
 [37]  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE FALSE FALSE  TRUE FALSE FALSE
 [49]  TRUE  TRUE  TRUE FALSE  TRUE FALSE FALSE FALSE FALSE FALSE  TRUE FALSE
 [61] FALSE  TRUE  TRUE FALSE  TRUE  TRUE  TRUE  TRUE  TRUE  TRUE FALSE  TRUE
 [73]  TRUE FALSE FALSE FALSE FALSE  TRUE FALSE  TRUE FALSE FALSE  TRUE FALSE
 [85]  TRUE  TRUE FALSE FALSE  TRUE  TRUE FALSE  TRUE FALSE  TRUE  TRUE FALSE
 [97] FALSE  TRUE FALSE  TRUE
```

```r
annMat$age <- runif(40, 20, 100)
```

```
> annMat$age
 [1] 39.15223 91.67047 31.89165 34.94808 81.90170 56.64862 60.96117 94.93440
 [9] 81.40003 25.23836 31.19239 52.49377 21.39916 69.80351 35.39081 59.85530
[17] 98.32359 54.71419 54.07249 28.50559 99.30387 34.40504 48.31153 79.85451
[25] 34.39170 82.29788 40.88654 94.60792 72.44746 92.18129 98.80929 90.62127
[33] 30.07691 38.08329 46.87385 36.55873 60.62178 36.80180 63.71794 92.76238
```

And in order to access the entire metadata `data.frame` the shortcuts of `$.` and `@.` are provided.

```
> head(annMat@.)
   chr      pos insideGene
1 chr2 485484.6      FALSE
2 chr2 921341.1      FALSE
3 chr3 222248.9       TRUE
4 chr2 652228.8       TRUE
5 chr3 391665.7      FALSE
6 chr1  67850.5       TRUE

> head(annMat$.)
  group gender      age
1  case      M 39.15223
2  case      F 91.67047
3  case      F 31.89165
4  case      M 34.94808
5  case      F 81.90170
6  case      F 56.64862
```

So to change the entire row or column metadata `data.frame` we can use:

```r
annMat@. <- data.frame(ID=1:100, gene=sample(LETTERS, 100, replace=TRUE))
```

```
> head(annMat@.)
  ID gene
1  1    J
2  2    A
3  3    Q
4  4    C
5  5    Z
6  6    U
```

```r
annMat$. <- data.frame(ID=1:40, weight=runif(40, 50, 150))
```

```
> head(annMat$.)
  ID    weight
1  1  53.34811
2  2  81.50472
3  3  62.81356
4  4 130.11996
5  5  83.06051
6  6 100.38434
```

And to delete row or column metadata simply set it to NULL:

```r
annMat@ID <- NULL
```

```
annMat@ID
NULL
```

When operations on *annMatrix* object involve functions that don't loose the class,
the result is a proper *annMatrix* object:

```
> scale(annMat)
      [,1]       [,2]       [,3]       [,4]       [,5]       [,6]       [,7]       [,8]       [,9]       [,10]      [,11]
 [1,] -0.0333005 -0.5244656 -0.9684015  1.2458794 -1.3281968  0.8199270  0.6216845  0.0930360 -0.0062679  1.1739130        ...
 [2,]  0.9590426 -1.7700789 -0.0968433  2.0416535 -0.4082146 -0.9917506  0.9929224 -1.3473413  0.2708556 -0.4514116        ...
 [3,] -0.2514444  0.3685842 -0.2198210 -0.5846271  1.5087355 -1.5056823  0.9654725  1.6677376 -1.3779349  1.1998286        ...
 [4,]  0.0736748  1.0128957  0.4648994  0.1533488  0.5296743  1.8649017  0.1904504  0.0022481  0.1348570  1.4533272        ...
 [5,] -1.7999049 -0.6426260  0.1500222 -0.6788104  0.2114061 -0.4556345  0.0422952 -1.5552116 -2.2625441  0.5878995        ...
 [6,]  1.3712172 -0.6258753  1.6475132  1.0099597  0.1723477  0.4558207  0.8313461 -0.2990253  1.6342545  0.8134639        ...
 [7,]  0.1168184 -1.8466586 -0.9883717  0.3174617  1.1537071  1.5418098 -0.5228040 -0.0606207 -0.1932585  1.6438674        ...
 [8,] -0.7458176  0.4467622  0.6968101 -0.2741929  0.5566839 -0.0095409  0.5016966 -0.7980751  0.1564716  0.7645529        ...
 [9,]  0.5284507  0.9299474 -0.6087965  0.1926942 -1.9484291 -0.5261878 -0.0833870  0.4604152 -0.0575127  0.5065520        ...
[10,]  0.5437470  1.3392827  0.3501167 -0.0167040  0.0618831 -0.0112722  0.2019460  1.0843049  0.7528232 -1.2072260        ...
[11,]        ...        ...        ...        ...        ...        ...        ...        ...        ...        ...        ...

rows:    100 ID, gene
columns: 40 ID, weight
```

But sometimes those will be lost - i.e. when doing `apply` on each column:

```r
mat <- apply(annMat, 2, cumsum)
```

```
class(mat)
[1] "matrix"
```

In such a case we can preserve the class and all the metadata by changing the matrix
instead of the entire variable via `[<-`:

```r
annMat[] <- apply(annMat, 2, cumsum)
```

```
class(annMat)
[1] "annMatrix" "matrix"
```


## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://bioconductor.org/packages/devel/bioc/manuals/Biobase/man/Biobase.pdf)

