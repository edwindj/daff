library(daff)
x <- iris
#change a value
x[1,1] <- 1000

patch <- diff_data(iris, x)
print(patch)
# apply patch
iris_patched <- patch_data(iris, patch)

iris_patched[1,1] == 1000
