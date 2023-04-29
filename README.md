# annmatrix #

R Annotated Matrix Object

![illustration](http://karolis.koncevicius.lt/data/annmatrix/illustration.png)


## Description ##

`annmatrix` object implements persistent row and column annotations for R matrices.

The use-case was born out of the need to better organize biomedical microarray and sequencing data within R.
But 'annmatrix' is readily applicable in other contexts where the data can be assembled into a matrix form with rows and columns representing distinct type of information.

The main advantage of 'annmatrix' over BioConductor implementations like [SummarizedExperiment](https://bioconductor.org/packages/release/bioc/html/SummarizedExperiment.html) and [AnnotatedDataFrame](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame) is simplicity.
Since 'annmatrix' is based on a regular matrix, and not a list or a data frame, it behaves like a regular matrix and can be directly passed to various methods that expect a matrix for an input.


## Installation ##

Using `remotes` library:

```r
remotes::install_github("karoliskoncevicius/annmatrix")
```


## Demonstration ##

Say, you have a small gene expression dataset with 10 genes measured across 6 samples.

```r
mat <- matrix(rnorm(10 * 6), nrow = 10, ncol = 6)
```

And some additional information about those genes and samples.

```r
# sample annotations
group   <- rep(c("case", "control"), each=3)
sex     <- sample(c("M", "F"), 6, replace = TRUE)

coldata <- data.frame(group = group, sex = sex)

# gene annotations
chromosome <- sample(c("chr1", "chr2", "chr3"), 10, replace = TRUE)
position   <- runif(10, 0, 1000000)

rowdata <- data.frame(chr = chromosome, pos = position)
```

`annmatrix` allows you to attach this additional information to the rows and columns of the original matrix.

```r
X <- annmatrix(mat, rowdata, coldata)
```

When printed `annmatrix` shows 4 first + the last row and 4 first + the last column from the matrix.
All the available row and column annotations are listed under the printed matrix.

```r
X

             [,1]        [,2]        [,3]        [,4]                    [,6]
 [1,] -0.66184983 -0.38282188 -1.26681476 -1.42199245 ........... -1.86544873
 [2,]  1.71895416  0.29942160 -0.19858329 -0.32822829 ...........  1.82998433
 [3,]  2.12166699  0.67423976  0.13886578  0.28457007 ........... -0.99111590
 [4,]  1.49715368 -0.29281632 -0.27933600  0.71933588 ........... -1.45043462
      ........... ........... ........... ........... ........... ...........
[10,]  1.04318309  1.08808601 -1.42776759  0.01587026 ........... -0.14174471

rann: chr, pos
cann: group, sex
```

Custom operators `@` and `$` are provided for convenient manipulation of row and column metadata.


```r
X@chr

 [1] "chr2" "chr1" "chr1" "chr3" "chr1" "chr1" "chr1" "chr2" "chr1" "chr2"
```

```r
X$group

 [1] "case"    "case"    "case"    "control" "control" "control"
```

They also can be used in adjust the annotations.

```r
X@pos

 [1]  43636.69 515054.59 970481.16  50346.18 725297.64 785234.14 725039.28 145226.04 928290.06 151757.38

X@pos <- X@pos * 10

X@pos

 [1] 6388883.5 3526169.4 5448169.2 3757517.6 8722369.9 4407579.6 2853758.3 2584070.9 7097369.0  728660.1
```

Or create new ones.

```r
X$age <- seq(10, 60, 10)
X$age

 [1] 10 20 30 40 50 60
```

When an empty name is provided it will return the whole annotation `data.frame`.

```r
X$''

    group sex age
1    case   F  10
2    case   M  20
3    case   M  30
4 control   M  40
5 control   M  50
6 control   M  60
```

When subsetting the `annmatrix` object all the annotations are correctly adjusted and class is preserved.


```r
X_case <- X[, X$group == "case"]
X_case

            [,1]       [,2]       [,3]
 [1,] -0.6618498 -0.3828219 -1.2668148
 [2,]  1.7189542  0.2994216 -0.1985833
 [3,]  2.1216670  0.6742398  0.1388658
 [4,]  1.4971537 -0.2928163 -0.2793360
      .......... .......... ..........
[10,]  1.0431831  1.0880860 -1.4277676

rann: chr, pos
cann: group, sex, age
```

```r
X_case$''

  group sex age
1  case   F  10
2  case   M  20
3  case   M  30
```

However in order to be consistent with `matrix` the class is dropped when selecting only a single row or column.

```r
X[1,]

 [1] -0.6618498 -0.3828219 -1.2668148 -1.4219925 -0.4311744 -1.8654487
```

But just like with a matrix we can enforce it to preserve all the annotations and class by setting `drop=FALSE`.


```r
X[1,, drop=FALSE]

           [,1]       [,2]       [,3]       [,4]                  [,6]
[1,] -0.6618498 -0.3828219 -1.2668148 -1.4219925 .......... -1.8654487

rann: chr, pos
cann: group, sex, age
```

Operations on `annmatrix` object don't loose the class.


```r
X > 0

       [,1]  [,2]  [,3]  [,4]        [,6]
 [1,] FALSE FALSE FALSE FALSE ..... FALSE
 [2,]  TRUE  TRUE FALSE FALSE .....  TRUE
 [3,]  TRUE  TRUE  TRUE  TRUE ..... FALSE
 [4,]  TRUE FALSE FALSE  TRUE ..... FALSE
      ..... ..... ..... ..... ..... .....
[10,]  TRUE  TRUE FALSE  TRUE ..... FALSE

rann: chr, pos
cann: group, sex, age
```

```r
X <- X - rowMeans(X)
X

             [,1]        [,2]        [,3]        [,4]                    [,6]
 [1,]  0.34316717  0.62219512 -0.26179776 -0.41697545 ........... -0.86043172
 [2,]  1.10162165 -0.31791091 -0.81591579 -0.94556080 ...........  1.21265182
 [3,]  1.74344169  0.29601446 -0.23935952 -0.09365523 ........... -1.36934120
 [4,]  1.47470725 -0.31526276 -0.30178244  0.69688945 ........... -1.47288106
      ........... ........... ........... ........... ........... ...........
[10,]  0.94789225  0.99279517 -1.52305843 -0.07942058 ........... -0.23703556

rann: chr, pos
cann: group, sex, age
```

Matrix transpose will preserve the class and correctly adjust row and column annotations.

```r
t(X)

            [,1]        [,2]        [,3]        [,4]                   [,10]
[1,]  0.34316717  1.10162165  1.74344169  1.47470725 ...........  0.94789225
[2,]  0.62219512 -0.31791091  0.29601446 -0.31526276 ...........  0.99279517
[3,] -0.26179776 -0.81591579 -0.23935952 -0.30178244 ........... -1.52305843
[4,] -0.41697545 -0.94556080 -0.09365523  0.69688945 ........... -0.07942058
     ........... ........... ........... ........... ........... ...........
[6,] -0.86043172  1.21265182 -1.36934120 -1.47288106 ........... -0.23703556

rann: group, sex, age
cann: chr, pos
```

Principal component analysis with `prcomp` will add row and column annotations to the resulting objects.
Furthermore, matrix cross-product will preserve all annotations that are possible to preserve after the product.
Here is an example where information is carried over after applying PCA rotation to transform a new dataset.

```r
pca <- prcomp(t(X))
pca$rotation

              PC1         PC2         PC3         PC4                     PC6
 [1,]  0.17186228 -0.06111446  0.28479933  0.34143265 ...........  0.06141574
 [2,]  0.07770596  0.56511346 -0.15143694  0.26206867 ........... -0.05690171
 [3,]  0.48808049  0.04486714  0.31834335 -0.16657847 ...........  0.57896252
 [4,]  0.34355333  0.02691052  0.45134983 -0.56375589 ........... -0.52045090
      ........... ........... ........... ........... ........... ...........
[10,]  0.32535557  0.32483324  0.07792832  0.15417554 ...........  0.21093439

rann: chr, pos
cann: pc, sd, var, var_explained


pca$rotation$var_explained

 [1] 3.976151e-01 2.492482e-01 1.991826e-01 8.899235e-02 6.496171e-02 3.582514e-33


y    <- matrix(rnorm(20), ncol=2)
info <- data.frame(smoker = c(TRUE, FALSE))
Y    <- annmatrix(y, cann = info)

Y_scores <- t(pca$rotation) %*% Y

Y_scores@''

     pc           sd          var var_explained
PC1 PC1 1.853695e+00 3.436186e+00  3.976151e-01
PC2 PC2 1.467652e+00 2.154001e+00  2.492482e-01
PC3 PC3 1.311996e+00 1.721335e+00  1.991826e-01
PC4 PC4 8.769670e-01 7.690712e-01  8.899235e-02
PC5 PC5 7.492653e-01 5.613986e-01  6.496171e-02
PC6 PC6 1.759547e-16 3.096006e-32  3.582514e-33


Y_scores$''

  smoker
1   TRUE
2  FALSE
```

And, of course, you get all the goodies that comes from storing your data as a matrix.

```r

# medians of all genes on chromosome 1

library(matrixStats)
colMedians(X[X@chr == "chr1",])

 [1]  0.50924058  0.36853396 -0.45264119 -0.05081974 -0.76821029  0.28775099


# Student's t-test between cases and controls on each gene

library(matrixTests)
row_t_welch(X[, X$group == "case"], X[, X$group == "control"])

   obs.x obs.y obs.tot      mean.x      mean.y   mean.diff     var.x       var.y    stderr       df   statistic     pvalue    conf.low  conf.high mean.null alternative conf.level
1      3     3       6  0.23452151 -0.23452151  0.46904303 0.2042138 0.539252812 0.4978174 3.324799  0.94219888 0.40938118 -1.03117801  1.9692641         0   two.sided       0.95
2      3     3       6 -0.01073502  0.01073502 -0.02147004 0.9900052 1.209717678 0.8562949 3.960489 -0.02507318 0.98120897 -2.40830919  2.3653691         0   two.sided       0.95
3      3     3       6  0.60003221 -0.60003221  1.20006442 1.0521953 0.458693605 0.7096687 3.465290  1.69102072 0.17701597 -0.89618888  3.2963177         0   two.sided       0.95
4      3     3       6  0.28588735 -0.28588735  0.57177470 1.0600150 1.208254422 0.8695342 3.982988  0.65756433 0.54687800 -1.84651142  2.9900608         0   two.sided       0.95
5      3     3       6  0.33994416 -0.33994416  0.67988832 0.1464459 0.805234743 0.5632290 2.704178  1.20712595 0.32229828 -1.22875761  2.5885343         0   two.sided       0.95
6      3     3       6  0.55006644 -0.55006644  1.10013288 1.1394478 1.854029064 0.9989122 3.784353  1.10133089 0.33582082 -1.73674581  3.9370116         0   two.sided       0.95
7      3     3       6  0.77470470 -0.77470470  1.54940939 1.0277400 0.442597183 0.7000803 3.453110  2.21318815 0.10200101 -0.52196414  3.6207829         0   two.sided       0.95
8      3     3       6  0.58210377 -0.58210377  1.16420753 0.1554729 0.272378334 0.3776468 3.722110  3.08279483 0.04054727  0.08408593  2.2443291         0   two.sided       0.95
9      3     3       6 -0.60733219  0.60733219 -1.21466438 0.0915277 0.140812981 0.2782928 3.827762 -4.36469899 0.01324089 -2.00123583 -0.4280929         0   two.sided       0.95
10     3     3       6  0.13920966 -0.13920966  0.27841933 2.0728555 0.007295719 0.8326967 2.014078  0.33435864 0.76971912 -3.28049265  3.8373313         0   two.sided       0.95
```


## Technical Details ##

`annmatrix` uses R's S3 class system to extend the base `matrix` class in order to provide it with persistent annotations that are associated with rows and columns.
Technically `annmatrix` object is just a regular R `matrix` with additional `data.frame` attributes `.annmatrix.rann` and `.annmatrix.cann` that are preserved after sub-setting and other matrix-specific operations.
As a result, every function that works on a `matrix` by design should work the same way with `annmatrix`.


## See Also ##

Similar ideas can be found in:

1. [Henrik Bengtsson's "wishlist for R"](https://github.com/HenrikBengtsson/Wishlist-for-R/issues/2)
2. [BioConductor's AnnotatedDataFrame object](https://www.rdocumentation.org/packages/Biobase/versions/2.32.0/topics/AnnotatedDataFrame)

