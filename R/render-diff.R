#' Render a diff table to html
#'
#' @param diff object
#' @param file to write to
#'@export
render_diff <- function(diff, file=""){
  ctx <- diff$ctx
  cat(ctx$call("render_diff", I(diff$var_name)), file = file)
}

