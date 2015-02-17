#' patch data
#'
#'@export
patch_data <- function(data, patch){
  ctx <- get_context()
  tv <- TableView(ctx, data)
  ctx$call("patch_data", I(tv$var_name), I(patch$var_name))
  tv$get_data()
}
