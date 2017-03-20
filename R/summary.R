#' @export
summary.data_diff <- function(object, ...){
  patch_data <- object$get_data()
  col_names <- names(patch_data)

  rows_changed <- sum(patch_data[[1]] == "->")
  rows_added   <- sum(patch_data[[1]] == "+++")
  rows_removed <- sum(patch_data[[1]] == "---")

  cols_added   <- sum(col_names == "+++")
  cols_removed <- sum(col_names == "---")

  structure(
    list( patch_data = patch_data
        , rows_changed  = rows_changed
        , rows_removed  = rows_removed
        , rows_added    = rows_added
        , cols_added    = cols_added
        , cols_removed  = cols_removed
        , data_names    = attr(object, "data_names")
        ),
    class = "data_diff_summary"
  )
}

print.data_diff_summary <- function(x, n=6, ...){
  cat("\nData diff:\n")

  cat(" Comparison:", sQuote(x$data_names$data_ref), "vs.", sQuote(x$data_names$data), "\n")

  cat(" Rows: changed: ", x$rows_changed, ",", sep="")
      cat(" removed: ", x$rows_removed, ",", sep="")
      cat(" added  : ", x$rows_added,        sep="")
  cat("\n")

  cat(" Columns: added:", x$cols_added, ",")
      cat(" removed:", x$cols_removed, "\n")
  cat("\n")

  cat("  First and last", n, "patch lines:\n")
  p <- rbind(head(x$patch_data, n=n),
             "..."=rep("...", length=ncol(x$patch_dat)),
             tail(x$patch_data, n=n)
             )
  print(p, ...)
  cat("\n")
}


### test

# y <- iris[1:4,]
# x <- y
#
# x <- head(x,2) # remove a row
# x[1,1] <- 10 # change a value
# x$hello <- "world"  # add a column
# x$Species <- NULL # remove a column
#
# # modified
# x <- rbind(x, c(3, 3, 3, 3, "test"))
# x <- x[-2,]
#
# patch <- diff_data(y, x)
# summary(patch)
