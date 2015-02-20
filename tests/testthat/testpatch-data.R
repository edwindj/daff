context("patch")

test_that("Empty patch works",{
  x <- data.frame(a=1, b=2)
  y <- x
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})

test_that("Diff changed value works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$a <- 10
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})


test_that("Adding row works",{
  x <- data.frame(a=1, b=2)
  y <- rbind(x,x)
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})

test_that("Removing row works",{
  x <- data.frame(a=1:2, b=2:3)
  y <- x[1,]
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})


test_that("Adding column works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$c <- 10
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})

test_that("Removing column works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$b <- NULL
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})

test_that("Changing a factor works",{
  x <- data.frame(a=factor(c("A","B")), b=1:2)
  y <- x
  y$a[1] <- "B"
  patch <- diff_data(x,y)
  expect_equal(patch_data(x, patch), y)
})
