y <- iris[1:3,]
x <- y

x <- head(x,2) # remove a row
x[1,1] <- 10 # change a value
x$hello <- "world"  # add a column
x$Species <- NULL # remove a column

patch <- diff_data(y, x)
render_diff(patch, title="compare x and y", pretty = TRUE)

#apply patch
y_patched <- patch_data(y, patch)
