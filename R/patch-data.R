#' patch data
#'
#'@export
patch_data <- function(data, patch){
  stopifnot(inherits(patch, "TableView"))
  ctx <- patch$ctx
  tv <- TableView(ctx, data)
  ctx$call("patch_data", I(tv$var_name), I(patch$var_name))
  tv$get_data()
}
