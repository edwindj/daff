#' @export
summary.data_diff <- function(object, ...){
  patch_data <- object$get_data()

  # The dataframe column names *usually* contain the data's column names, but
  # can also be held in rows 1 or 2
  col.names <- colnames(patch_data)
  if(col.names[1] != "@@")
  {
    first.rows <- min(3, nrow(patch_data))
    first.cols <- min(3, ncol(patch_data))
    topleft <- patch_data[1:first.rows, 1:first.cols]
    colnames_row <- which(topleft=="@@", arr.ind = TRUE)[,"row"][1]
    if(length(colnames_row)==0) stop("Unable to determine column names.")
    col.names <- unlist(patch_data[colnames_row,])
  }

  # The column containg flags can be either [,1] or [,2] depending on whether
  # row change indexes are present, but can be identified by the column
  # containing '@@' in row 2.  NB: It would be nice if the daff object containd these indexes
  flag_col  <- which(col.names=='@@')[1]

  row_flags <- patch_data[,flag_col]
  col_flags <- patch_data[1,]
  if(any(grepl("[A-Za-z0-9]", col_flags)) ) # Flag row shouldn't have any text in it
    col_flags <- rep("", ncol(patch_data))

  dims <- attr(object, "data_dims")

  # count row modifications
  rows_before <-  dims$"data_ref"[1]
  rows_after   <- dims$"data"   [1]
  rows_changed <- sum(row_flags %in% c("->", "-->"))
  rows_added   <- sum(row_flags == "+++")
  rows_removed <- sum(row_flags == "---")

  # count column modifications
  cols_before <-  dims$"data_ref"[2]
  cols_after   <- dims$"data"    [2]
  cols_added   <- sum(col_flags == "+++")
  cols_removed <- sum(col_flags == "---")

  # Finding changes columns requires looking at individual cells:
  # 1) Extract only rows flagged as containing a change:
  changed_rows <- patch_data[row_flags %in% c("->", "-->"), -(1:flag_col)]
  # 2) Identify which columns contain "-->"
  cols_change_flag <- sapply( changed_rows, function(col_data) any(grepl("->", col_data, fixed=TRUE ) ) )
  # 3) Count the columns
  cols_changed     <- sum(cols_change_flag)

  structure(
    list( patch_data = patch_data
        , rows_before   = rows_before
        , rows_after    = rows_after
        , rows_changed  = rows_changed
        , rows_removed  = rows_removed
        , rows_added    = rows_added

        , cols_before   = cols_before
        , cols_after    = cols_after
        , cols_changed  = cols_changed
        , cols_added    = cols_added
        , cols_removed  = cols_removed

        , data_names    = attr(object, "data_names")
        , data_dims     = attr(object, "data_dims" )
        ),
    class = "data_diff_summary"
  )
}


#' @export
#' @importFrom utils head tail
print.data_diff_summary <- function(x, n=6, show.patch=TRUE, ...){

  if(x$rows_before == x$rows_after)
    rows_before_after <- x$rows_before
  else
    rows_before_after <- paste0(x$rows_before, " --> ", x$rows_after)

  if(x$cols_before == x$cols_after)
    cols_before_after <- x$cols_before
  else
    cols_before_after <- paste0(x$cols_before, " --> ", x$cols_after)


    cat("\nData diff:\n")

  cat(" Comparison:", sQuote(x$data_names$data_ref), "vs.", sQuote(x$data_names$data), "\n")

  row.data <- c("#"    = rows_before_after,
                Changed= x$rows_changed,
                Removed= x$rows_removed,
                Added  = x$rows_added
                )

  col.data <- c("#"    = cols_before_after,
                Changed=x$cols_changed,
                Removed=x$cols_removed,
                Added  =x$cols_added
                )

  tab <-  rbind(Rows = row.data,
                Columns = col.data)

  print(tab)

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
