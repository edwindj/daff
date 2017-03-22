#' @export
summary.data_diff <- function(object, ...){
  patch_data <- object$get_data()

  col.names <- patch_data[2, ] # row 2 always contains data column names, while
                               # names(...) may contain column change indexes..
  
  # The column containg flags can be either [,1] or [,2] depending on whether
  # row change indexes are present, but can be identified by the column 
  # containing '@@' in row 2.  NB: It would be nice if the daff object containd these indexes
  flag_col  <- which(col.names=='@@')[1]

  row_flags <- patch_data[,flag_col]
  col_flags <- patch_data[1,]
  
  rows_changed <- sum(row_flags == "-->")
  rows_added   <- sum(row_flags == "+++")
  rows_removed <- sum(row_flags == "---")
  rows_total   <- length(row_flags) - 2 

  cols_added   <- sum(col_flags == "+++")
  cols_removed <- sum(col_flags == "---")

  # Finding changes columns requires looking at individual cells, so
  # first extract only rows flagged as containing a change:
  changed_rows <- patch_data[row_flags == "-->", -(1:flag_col)]
  # Next, identify which columns contain "-->"
  cols_change_flag <- sapply( patch_data, function(col_data) any(grepl("-->", col_data)) )
  cols_changed     <- sum(cols_change_flag)
  # Finally, count them                             
  cols_total   <- length(cols_change_flag)

  structure(
    list( patch_data = patch_data
        , rows_changed  = rows_changed
        , rows_removed  = rows_removed
        , rows_added    = rows_added
        , rows_total    = rows_total
        , cols_changed  = cols_changed
        , cols_added    = cols_added
        , cols_removed  = cols_removed
        , cols_total    = cols_total
        , data_names    = attr(object, "data_names")
        ),
    class = "data_diff_summary"
  )
}


#' @export
#' @importFrom utils head tail
print.data_diff_summary <- function(x, n=6, show.patch=TRUE, ...){
  cat("\nData diff:\n")

  cat(" Comparison:", sQuote(x$data_names$data_ref), "vs.", sQuote(x$data_names$data), "\n")

  row.data <- c(Changed=x$rows_changed, 
                Removed=x$rows_removed, 
                Added  =x$rows_added,
                Total  =x$rows_total)

  col.data <- c(Changed=x$cols_changed, 
                Removed=x$cols_removed, 
                Added  =x$cols_added,
                Total  =x$cols_total)  
  
  tab <-  rbind(Rows = row.data, 
                Columns = col.data)
  
  print(tab)

  if(show.patch)
  {
    cat("  First", n, "and last", n, "patch lines:\n")
    p <- rbind(head(x$patch_data, n=n),
               "..."=rep("...", length=ncol(x$patch_dat)),
               tail(x$patch_data, n=n)
    )
    print(p, ...)
    cat("\n")
  }

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
