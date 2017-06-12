#' @export
summary.data_diff <- function(object, ...)
{
  retval <- attr(object, "summary") # everything is pre-computed

  retval$data <- object$get_matrix()
  class(retval) <- "data_diff_summary"

  retval
}

#' @importFrom utils head tail
print.data_diff_summary <- function(x, n=6, show.patch=TRUE, ...)
{
  cat("\nData diff:", sQuote(x$source_name), "vs.", sQuote(x$target_name), "\n")

  row.data <- c("#"       = x$row_count_change_text,
                Modified  = x$row_updates,
                Reordered = x$row_reorders,
                Deleted   = x$row_deletes,
                Added     = x$row_inserts
                )

  col.data <- c("#"       = x$col_count_change_text,
                Modified  = x$col_updates,
                Reordered = x$col_reorders,
                Deleted   = x$col_deletes,
                Added     = x$col_inserts
                )

  tab <-  rbind(Rows = row.data,
                Columns = col.data)

  print(tab, quote=FALSE)

  invisible(x)
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
