library(annmatrix)
source("utils/test.r")

#=================================== ERRORS ====================================

test(annmatrix(mean))                                         # closure cannot be transformed to a matrix
test(annmatrix(environment()))                                # environment cannot be transformed to a matrix

test(annmatrix(iris, rann = data.frame()))                    # incorrect number of row annotations (zero)
test(annmatrix(iris, rann = data.frame(a = 1, b = 2)))        # incorrect number of row annotations (one)
test(annmatrix(iris, rann = data.frame(1:3)))                 # incorrect number of row annotations (too low)
test(annmatrix(iris, rann = data.frame(1:200)))               # incorrect number of row annotations (too high)

test(annmatrix(iris, cann = data.frame()))                    # incorrect number of column annotations (zero)
test(annmatrix(iris, cann = data.frame(a = 1, b = 2)))        # incorrect number of column annotations (one)
test(annmatrix(iris, cann = data.frame(1:3)))                 # incorrect number of column annotations (too low)
test(annmatrix(iris, cann = data.frame(1:200)))               # incorrect number of column annotations (too high)

test(annmatrix(iris, data.frame(), data.frame()))             # when both incorrect - error about row annotations


#============================= EMPTY CONSTRUCTORS ==============================

test(annmatrix())                                             # empty call results in an empty matrix
test(annmatrix(data.frame(), data.frame()))                   # allows specifying empty data.frames for annotations

test(annmatrix(logical()))                                    # empty logical results in zero-row one-column logical
test(annmatrix(integer()))                                    # empty integer results in zero-row one-column integer
test(annmatrix(numeric()))                                    # empty numeric results in zero-row one-column numeric
test(annmatrix(character()))                                  # empty character results in zero-row one-column character
test(annmatrix(complex()))                                    # empty complex results in zero-row one-column complex
test(annmatrix(list()))                                       # empty list results in zero-row one-column list

x <- matrix(integer(), nrow = 0, ncol = 3)                    # zero number of rows
test(annmatrix(x))                                            # sets the correct number of rows and columns
test(annmatrix(x, rann = data.frame()))                       # allows specifying empty row annotations
test(annmatrix(x, cann = data.frame(a = letters[1:3])))       # allows specifying annotations for columns

x <- matrix(integer(), nrow = 3, ncol = 0)                    # zero number of columns
test(annmatrix(x))                                            # sets the correct number of rows and columns
test(annmatrix(x, cann = data.frame()))                       # allows specifying empty column annotations
test(annmatrix(x, rann = data.frame(a = letters[1:3])))       # allows specifying annotations for rows


#=============================== VARIOUS TYPES =================================

test(annmatrix(c(TRUE, FALSE)))                               # works with logical
test(annmatrix(1:2))                                          # works with integer
test(annmatrix(1:2/2))                                        # works with real
test(annmatrix(letters[1:2]))                                 # works with character
test(annmatrix(as.complex(1:2)))                              # works with complex
test(annmatrix(matrix(1:6, nrow=2)))                          # works with matrix
test(annmatrix(list(1, 1:2, letters[1:3])))                   # works with list


#=============================== REGULAR CASES =================================

# check for preserving correct result, annotations, and row/column names
x    <- matrix(1:6, nrow=2, ncol=3, dimnames=list(letters[1:2], LETTERS[1:3]))
rann <- data.frame(id = 1:2, chr = c("c1", "c2"), pos = c(10, 20))
cann <- data.frame(name = c("A", "B", "C"), age = c(20, 40, 60))

test(annmatrix(x))                                            # without annotations
test(annmatrix(x, rann = rann))                               # only row annotations
test(annmatrix(x, cann = cann))                               # only column annotations
test(annmatrix(x, rann = rann, cann = cann))                  # both annotations

# TODO: check for list matrices and list entries in annotations
