x <- iris[1:2,]
x[1,1] <- 10

diff <- diff_data(iris[1:2,], x)
# render_diff(diff) # will show an html diff

render_diff(diff, file="")

