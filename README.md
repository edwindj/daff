# Daff, diff for data

daff is an R package that wraps the daff.js library of Paul Fitzpatrick [http://paulfitz.github.io/daff/](http://paulfitz.github.io/daff/) using the [V8 package](https://github.com/jeroenooms/v8)

[![Build Status](https://travis-ci.org/edwindj/daff.png?branch=master)](https://travis-ci.org/edwindj/daff)

Work in progress.

TODO:

- add render functionality
- add htmlwidgets
- add merge functionality

# Install

`daff` is not yet on CRAN but can be installed for now with `devtools`

```S
devtools::install_github("edwindj/daff")
```
Note that it is still work in progress!

# Usage

```S
library(daff)
x <- iris
#change a value
x[1,1] <- 1000

patch <- diff_data(iris, x)
print(patch)

# write a patch to disk
write_diff(patch, "patch.csv")

# read a diff from disk
patch <- read_diff("patch.csv")

# apply patch
iris_patched <- patch_data(iris, patch)

iris_patched[1,1] == 1000
```
