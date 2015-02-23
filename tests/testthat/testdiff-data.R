context("diff")

test_that("Empty diff works",{
  x <- data.frame(a=1, b=2)
  y <- x
  expect_equal(diff_data(x,y)$to_csv(), "@@,a,b\n")
})

test_that("Diff changed value works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$a <- 10
  expect_equal(diff_data(x,y)$to_csv(), "@@,a,b\n->,1->10,2\n")
})


test_that("Adding row works",{
  x <- data.frame(a=1, b=2)
  y <- rbind(x,x)
  expect_equal(diff_data(x,y)$to_csv(), "@@,a,b\n,1,2\n+++,1,2\n")
})

test_that("Removing row works",{
  x <- data.frame(a=1:2, b=2:3)
  y <- x[1,]
  expect_equal(diff_data(x,y)$to_csv(), "@@,a,b\n,1,2\n---,2,3\n")
})


test_that("Adding column works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$c <- 10
  expect_equal(diff_data(x,y)$to_csv(), "!,,,+++\n@@,a,b,c\n+,1,2,10\n")
})

test_that("Removing column works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y$b <- NULL
  expect_equal(diff_data(x,y)$to_csv(), "!,,---\n@@,a,b\n")
})

test_that("Changing to NA works", {
  y <- x <- data.frame(a=1, b=2)
  y$a <- NA
  expect_equal(diff_data(x,y)$to_csv(), "@@,a,b\n->,1->NULL,2\n")
})


