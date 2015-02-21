parent <- a <- b <- iris[1:3,]
a[1,1] <- 10
b[2,1] <- 11
# succesful merge
merge_data(parent, a, b)

parent <- a <- b <- iris[1:3,]
a[1,1] <- 10
b[1,1] <- 11
# conflicting merge (both a and b change same cell)
merge_data(parent, a, b)

