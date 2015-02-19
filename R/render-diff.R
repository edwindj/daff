#' Render a data diff  to html
#'
#' \code{render_diff}
#' \code{render_diff} will show a diff in html. When \code{view} is \code{TRUE} \code{render_diff} will show
#' the result in a browser.
#'
#' @example ./examples/render-diff.R
#' @param diff object generated with \code{\link{diff_data}}
#' @param file to write to
#' @param view \code{TRUE} or \code{FALSE}, if \code{TRUE} render_diff will show the diff
#' the browser
#'@export
render_diff <- function(diff, file=tempfile(fileext = ".html"), view=missing(file)){
  ctx <- diff$ctx
  html <- ctx$call("render_diff", I(diff$var_name))
  cat(html, file = file)
  if (view && file != ""){
    viewer <- getOption("viewer")
    if (!is.null(viewer) && is.function(viewer)){
      viewer(file)
    }else{
      utils::browseURL(file)
    }
  }
  invisible(html)
}

