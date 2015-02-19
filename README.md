# Daff, diff for data

daff is an R package that wraps the daff.js library of Paul Fitzpatrick [http://paulfitz.github.io/daff/](http://paulfitz.github.io/daff/) using the [V8 package](https://github.com/jeroenooms/v8)

Work in progress.
Working:

- diff: `diff_data`
- patch: `patch_data`
- write/read diff: `read_diff` and `write_diff`

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
y <- iris[1:3,]
x <- y

x <- head(x,2) # remove a row
x[1,1] <- 10 # change a value
x$hello <- "world"  # add a column
x$Species <- NULL # remove a column

patch <- diff_data(y, x)

# write a patch to disk
write_diff(patch, "patch.csv")

# read a diff from disk
patch <- read_diff("patch.csv")

# apply patch
y_patched <- patch_data(y, patch)
```

`render_diff(patch)` will generate the following HTML page:

![render_diff](examples/render_diff.png "render_diff")
