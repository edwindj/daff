#' Do a data diff
#'
#' Find differences with a reference data set. The diff can be used to \code{\link{patch_data}}, to store the difference
#' for documentation purposes using \code{\link{write_diff}} or to visualize the difference using \code{\link{render_diff}}
#'
#' @example ./examples/datadiff.R
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @param ids \code{character} identification columns (not yet working)
#' @param ignore \code{character} columns to ignore (not yet working)
#' @param context \code{integer} number of context rows (not yet working)
#' @param show_all \code{logical} show all rows or only changed rows?  (not yet working)
#' @return difference object
#' @export
#' @seealso differs_from
diff_data <- function(data_ref, data, ids=NULL, ignore=NULL, context=1L, show_all=FALSE){
  ctx <- get_context()
  tv <- TableView(ctx, data)
  tv_ref <- TableView(ctx, data_ref)
  tv_diff <- TableView(ctx) # does not yet exist

  # add target classes to diff
  tv_diff$mode <- sapply(data, storage.mode)
  tv_diff$is_factor <- sapply(data, is.factor)
  tv_diff$levels <- lapply(data, levels)
  #print(tv_diff$levels)

  ctx$assign("ids", ids)
  ctx$assign("ignore", ignore)
  ctx$assign("context", context)
  ctx$assign("show_all", show_all)

  diff <- paste0("diff(",tv_ref$var_name,",",tv$var_name,",ids, ignore, context, show_all)")
  ctx$assign(tv_diff$var_name, JS(diff))
  tv_diff
}


#' differs from,
#'
#' This is the same function as \code{\link{diff_data}} but with arguments
#' reversed. This is more useful when using \code{dplyr} and \code{magrittr}
#'
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @param ... not further specified
#' @return difference object
#' @export
#' @seealso diff_data
differs_from <- function(data, data_ref, ...){
  diff_data(data_ref=data_ref, data=data, ...)
}
