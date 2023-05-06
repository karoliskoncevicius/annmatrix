library(annmatrix)
source("utils/capture.r")


#--- errors --------------------------------------------------------------------

# doesn't work on objects that cannot be transformed to matrices
out <- capture(annmatrix(mean))
stopifnot(all.equal(out$error, "cannot coerce type 'closure' to vector of type 'any'"))


# incorrect number of row annotations (zero)
out <- capture(annmatrix(head(iris), rann = data.frame()))
stopifnot(all.equal(out$error, "Number of 'rann' rows must match the number of rows in 'x'"))

# incorrect number of row annotations (one)
out <- capture(annmatrix(head(iris), rann = data.frame(a = 1, b = 2)))
stopifnot(all.equal(out$error, "Number of 'rann' rows must match the number of rows in 'x'"))

# incorrect number of row annotations (too low)
out <- capture(annmatrix(head(iris), rann = data.frame(1:3)))
stopifnot(all.equal(out$error, "Number of 'rann' rows must match the number of rows in 'x'"))

# incorrect number of row annotations (too high)
out <- capture(annmatrix(head(iris), rann = data.frame(1:12)))
stopifnot(all.equal(out$error, "Number of 'rann' rows must match the number of rows in 'x'"))


# incorrect number of column annotations (zero)
out <- capture(annmatrix(head(iris), cann = data.frame()))
stopifnot(all.equal(out$error, "Number of 'cann' rows must match the number of columns in 'x'"))

# incorrect number of column annotations (one)
out <- capture(annmatrix(head(iris), cann = data.frame(a = 1, b = 2)))
stopifnot(all.equal(out$error, "Number of 'cann' rows must match the number of columns in 'x'"))

# incorrect number of column annotations (too low)
out <- capture(annmatrix(head(iris), cann = data.frame(1:3)))
stopifnot(all.equal(out$error, "Number of 'cann' rows must match the number of columns in 'x'"))

# incorrect number of column annotations (too high)
out <- capture(annmatrix(head(iris), cann = data.frame(1:12)))
stopifnot(all.equal(out$error, "Number of 'cann' rows must match the number of columns in 'x'"))


# when both incorrect - error about row annotations
out <- capture(annmatrix(head(iris), rann = data.frame(), cann = data.frame()))
stopifnot(all.equal(out$error, "Number of 'rann' rows must match the number of rows in 'x'"))


#--- empty constructor ---------------------------------------------------------

# empty call results in an empty matrix
res <- annmatrix()
stopifnot(all.equal(as.matrix(res), matrix(nrow=0, ncol=0)))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame()))

# allows specifying empty data.frames for annotations
res <- annmatrix(rann = data.frame(), cann = data.frame())
stopifnot(all.equal(as.matrix(res), matrix(nrow=0, ncol=0)))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame()))


#--- zero-length constructors --------------------------------------------------

# empty logical results in zero-row one-column logical
res <- annmatrix(logical())
stopifnot(all.equal(typeof(res), "logical"))
stopifnot(all.equal(as.matrix(res), matrix(logical())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# empty integer results in zero-row one-column integer
res <- annmatrix(integer())
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), matrix(integer())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# empty numeric results in zero-row one-column numeric
res <- annmatrix(numeric())
stopifnot(all.equal(typeof(res), "numeric"))
stopifnot(all.equal(as.matrix(res), matrix(numeric())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# empty character results in zero-row one-column character
res <- annmatrix(character())
stopifnot(all.equal(typeof(res), "character"))
stopifnot(all.equal(as.matrix(res), matrix(character())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# empty complex results in zero-row one-column complex
res <- annmatrix(complex())
stopifnot(all.equal(typeof(res), "complex"))
stopifnot(all.equal(as.matrix(res), matrix(complex())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# empty list results in zero-row one-column list
res <- annmatrix(list())
stopifnot(all.equal(typeof(res), "list"))
stopifnot(all.equal(as.matrix(res), matrix(list())))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))


#--- zero-row constructors -----------------------------------------------------

x <- matrix(integer(), nrow = 0, ncol = 10)

# sets the correct number of rows and columns
res <- annmatrix(x)
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1:10)))

# allows specifying empty row annotations
res <- annmatrix(x, rann = data.frame())
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(row.names=1:10)))

# allows specifying annotations for columns
res <- annmatrix(x, cann = data.frame(a = letters[1:10]))
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame()))
stopifnot(all.equal(res$'', data.frame(a = letters[1:10])))


#--- zero-columns constructors -------------------------------------------------

x <- matrix(integer(), nrow = 10, ncol = 0)

# sets the correct number of rows and columns
res <- annmatrix(x)
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame(row.names=1:10)))
stopifnot(all.equal(res$'', data.frame()))

# allows specifying empty column annotations
res <- annmatrix(x, cann = data.frame())
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame(row.names=1:10)))
stopifnot(all.equal(res$'', data.frame()))

# allows specifying annotations for rows
res <- annmatrix(x, rann = data.frame(a = letters[1:10]))
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), x))
stopifnot(all.equal(res@'', data.frame(a = letters[1:10])))
stopifnot(all.equal(res$'', data.frame()))


#--- constructors from a vector ------------------------------------------------

x <- 1:10

# construct the same matrix as regular matrix() with correct empty annotations
res <- annmatrix(x)
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(row.names=1:10)))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# allows spcifying row and column annotations
res <- annmatrix(x, rann = data.frame(letters[1:10]), cann = data.frame(1))
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(letters[1:10])))
stopifnot(all.equal(res$'', data.frame(1)))


#--- constructors from a matrix ------------------------------------------------

x <- matrix(1:10, nrow=2)

# construct the same matrix as regular matrix() with correct empty annotations
res <- annmatrix(x)
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(row.names=1:2)))
stopifnot(all.equal(res$'', data.frame(row.names=1:5)))

# allows spcifying row and column annotations
res <- annmatrix(x, rann = data.frame(letters[1:2]), cann = data.frame(1:5))
stopifnot(all.equal(typeof(res), "integer"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(letters[1:2])))
stopifnot(all.equal(res$'', data.frame(1:5)))


#--- constructors from a list --------------------------------------------------

x <- list(1:10, 1:10, 1:10)

# construct the same matrix as regular matrix() with correct empty annotations
res <- annmatrix(x)
stopifnot(all.equal(typeof(res), "list"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(row.names=1:3)))
stopifnot(all.equal(res$'', data.frame(row.names=1L)))

# allows spcifying row and column annotations
res <- annmatrix(x, rann = data.frame(letters[1:3]), cann = data.frame(1))
stopifnot(all.equal(typeof(res), "list"))
stopifnot(all.equal(as.matrix(res), as.matrix(x)))
stopifnot(all.equal(res@'', data.frame(letters[1:3])))
stopifnot(all.equal(res$'', data.frame(1)))


