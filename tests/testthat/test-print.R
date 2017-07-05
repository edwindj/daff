context("print")

test_that("print of small set works", {
  x <- data.frame(a=1, b=1)
  x_changed <- data.frame(a=1, b=100)
  diff <- diff_data(x, x_changed)
  expect_output_file(print(diff), file = "print_small.txt", update = FALSE)
})
