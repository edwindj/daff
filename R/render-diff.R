#' Render a data diff  to html
#'
#' \code{render_diff} will show a diff in html. When \code{view} is \code{TRUE} \code{render_diff} will show
#' the result in a browser.
#'
#' @example ./examples/render-diff.R
#' @param diff object generated with \code{\link{diff_data}}
#' @param file to write to
#' @param view \code{TRUE} or \code{FALSE}, if \code{TRUE} render_diff will show the diff
#' in the browser (only if R is used interactively)
#' @param fragment if \code{FALSE} the generated HTML will be a valid HTML document, otherwise it is a HTML fragment
#' @param pretty if \code{TRUE} use fancy utf8 characters to make arrows prettier.
#' @return generated html
#'@export
render_diff <- function( diff
                       , file=tempfile(fileext = ".html")
                       , view=interactive()
                       , fragment=FALSE
                       , pretty=FALSE
                       ){
  ctx <- diff$ctx
  html <- ctx$call("render_diff", JS(diff$var_name), fragment, pretty)
  cat(html, file = file)
  if (view && file != "" && interactive()){
    viewer <- getOption("viewer")
    if (!is.null(viewer) && is.function(viewer)){
      viewer(file)
    }else{
      utils::browseURL(file)
    }
  }
  invisible(html)
}

