#' Merge two tables based on a parent version
#'
#' \code{merge_data} provides a three-way merge: suppose two versions are based on a common
#' version, this function will merge tables \code{a} and \code{b}.
#'
#' If both \code{a} and \code{b} change the same table cell with a different value, this results in a
#' conflict. In that case a warning will be generated with the number of conflicts.
#' In the returned \code{data.frame} of a conflicting merge columns with conflicting values are of type
#' \code{character} and contain all three values coded as
#'
#' (parent) a /// b
#'
#' @param parent \code{data.frame}
#' @param a \code{data.frame} changed version of \code{parent}
#' @param b \code{data.frame} other changed version of \code{parent}
#' @return merged \code{data.frame}. When a merge has conflicts the columns of conflicting changes
#' are of type \code{character} and contain all three values.
#' @example ./examples/merge-data.R
#' @export
#' @seealso \code{\link{which_conflicts}}
merge_data <- function(parent, a, b){
  ctx <- get_context()
  tv_parent <- TableView(ctx, parent)
  tv_a <- TableView(ctx, a)
  tv_b <- TableView(ctx, b)

  res <- ctx$call( "merge_data"
                 , JS(tv_parent$var_name)
                 , JS(tv_a$var_name)
                 , JS(tv_b$var_name)
                 )

  merged <- tv_a$get_data()
  if (res$ok){
    is_factor <- sapply(parent, is.factor)
    storage_mode <- sapply(parent, storage.mode)
    for (m in names(merged)){
      if (isTRUE(unname(is_factor[m]))){
        merged[[m]] <- factor(merged[[m]])
      } else{
        if (!is.na(storage_mode[m])){
          storage.mode(merged[[m]]) <- storage_mode[m]
        }
      }
    }
  } else {
    warning( "\n\t", res$conflicts, " conflict(s) detected!"
           , "\n\tConflicting values are noted with '(((parent))) a /// b'."
           , "\n\tUse 'which_conflict' to find out which rows contain conflicting values."
           )
  }
  merged
}

#' return which rows of a merged \code{data.frame} contain conflicts
#'
#' return which rows of a merged \code{data.frame} contain conflicts.
#' @param merged \code{data.frame} merged data.frame with possible conflicts.
#' @return \code{integer} vector with row positions containing conflicts.
#' @export
#' @example ./examples/merge-data.R
#' @seealso \code{\link{merge_data}}
which_conflicts <- function(merged){
  #only character column can contain conflicts
  is_char <- sapply(merged, is.character) | sapply(merged, is.factor)
  conflicts <- lapply(merged[is_char], function(v){
    # TODO make this more reliable?
    grepl("///", v)
  })
  conflicts <- Reduce(`|`, conflicts)
  which(conflicts)
}

# x <- y <- iris[1:3,]
# x[1,1] <- 10
# y[2,1] <- 11
#
# merge_data(iris, x, y)
