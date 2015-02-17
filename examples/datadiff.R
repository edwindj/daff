library(daff)
x <- iris
x[1,1] <- 10
data_diff(x, iris)

