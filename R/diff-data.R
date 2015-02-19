#' Do a data diff
#'
#' Find differences with a reference data set.
#'
#' @example ./examples/datadiff.R
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @return difference object
#' @export
#' @seealso differs_from
diff_data <- function(data_ref, data){
  ctx <- get_context()
  tv <- TableView(ctx, data)
  tv_ref <- TableView(ctx, data_ref)
  tv_diff <- TableView(ctx) # does not yet exist
  # add target classes to diff
  tv_diff$mode <- sapply(data, mode)

  diff <- paste0("diff(",tv_ref$var_name,",",tv$var_name,")")
  ctx$assign(tv_diff$var_name, I(diff))
  tv_diff
}


#' differs from,
#'
#' This is the same function as \code{\link{diff_data}} but with arguments
#' reversed. This is more useful when using \code{dplyr} and \code{magrittr}
#'
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @return difference object
#' @export
#' @seealso diff_data
differs_from <- function(data, data_ref){
  diff_data(data_ref=data_ref, data=data)
}
