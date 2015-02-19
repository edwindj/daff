context("readwrite")

test_that("Writing and reading works",{
  x <- data.frame(a=1, b=2)
  y <- x
  y[1,1] <- 100

  patch <- diff_data(x,y)

  patch_file <- tempfile()

  write_diff(patch, patch_file)

  patch2 <- read_diff(patch_file)
  expect_equal(patch2$to_csv(), patch$to_csv())
})
