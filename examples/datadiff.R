library(daff)
x <- iris
x[1,1] <- 10
data_diff(x, iris)

dd <- data_diff(x, iris)
write_diff(dd, "test.csv")
