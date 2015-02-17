#' data diff
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @return difference object
#' @export
data_diff <- function(data, data_ref){
  ctx <- get_context()
  tv <- TableView(ctx, data)
  tv_ref <- TableView(ctx, data_ref)
  tv_diff <- TableView(ctx) # does not yet exist
  diff <- paste0("diff(",tv$var_name,",",tv_ref$var_name,")")
  ctx$assign(tv_diff$var_name, I(diff))
  tv_diff
}
