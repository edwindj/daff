
context("lumberjack logger")

test_that("lumberjack logger",{
  logger <- lbj_daff$new()
  meta=list(expr=expression({.*2}), src="{\n .*2\n}")
  logger$add(meta, women, 2*women)
  expect_equal(logger$n,1L)
  fl <- dir(logger$dir, full.names = TRUE)
  expect_equal(length(fl),1L)
  d <- read.csv(fl)
  expect_equal(nrow(d), nrow(women)*ncol(women))
  expect_equal(nrow(logger$logdata()), nrow(women)*ncol(women))
})
