y <- iris[1:3,]
x <- y

x <- head(x,2) # remove a row
x[1,1] <- 10 # change a value
x$hello <- "world"  # add a column
x$Species <- NULL # remove a column

patch <- diff_data(y, x)

# render_diff(diff) # will show an html diff
render_diff(patch, file="")

#apply patch
y_patched <- patch_data(y, patch)
