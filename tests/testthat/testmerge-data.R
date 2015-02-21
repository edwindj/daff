context("merge")

test_that("simple merge works", {
  parent <- a <- b <- data.frame(x=1, y=2)
  a[1,1] <- 10
  b[1,2] <- 11

  merged <- merge_data(parent, a, b)
  expect_equal(merged, data.frame(x=10, y=11))
})

test_that("Merge conflict", {
  parent <- a <- b <- data.frame(x=1, y=2)
  a[1,1] <- 10
  b[1,1] <- 11

  expect_warning(merged <- merge_data(parent, a, b))
  expect_equal(sapply(merged, class), c(x="character", y="integer"))
})

test_that("Merge with factor works", {
  parent <- a <- b <- data.frame(x=1, y=2, f=factor("A"))
  a[1,1] <- 10
  b[1,2] <- 11

  merged <- merge_data(parent, a, b)
  expect_equal(merged, data.frame(x=10, y=11, f=factor("A")))
})
