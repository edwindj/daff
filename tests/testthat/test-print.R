context("print")

test_that("print of small set works", {
  x <- data.frame(a=1, b=1)
  x_changed <- data.frame(a=1, b=100)
  diff <- diff_data(x, x_changed)

  output <-
"Daff Comparison: ‘x’ vs. ‘x_changed’
   a b
-> 1 1->100

"
  expect_output(print(diff), output = output, update = FALSE)
})
