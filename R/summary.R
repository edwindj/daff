#' @export
summary.data_diff <- function(object, ...)
{
  retval <- attr(object, "summary") # everything is pre-computed

  if(is.null(retval$col_updates))  # Until col_updates is supported, calculate locally
  {
    flags <- apply(object$get_matrix(), 2, function(X) any(grepl("-->", X)) )

    retval$col_updates <- sum(flags, na.rm=TRUE)
    #NB: if row_updates > 0, there may be row update markers in one column,
    #    so check and decrement if true.
    if(retval$row_updates > 0 && retval$col_updates > 0) retval$col_updates <- retval$col_updates - 1
  }

  retval$data <- object$get_matrix()
  class(retval) <- "data_diff_summary"

  retval
}

#' @importFrom utils head tail
print.data_diff_summary <- function(x, n=6, show.patch=TRUE, ...)
{
  cat("\nData diff:\n")

  cat(" Comparison:", sQuote(x$source_name), "vs.", sQuote(x$target_name), "\n")

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
