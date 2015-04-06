#' @importFrom V8 new_context JS
get_context <- function(){
  ctx <- V8::new_context("window")
  ctx$source(system.file("js/underscore.js", package="V8"))
  ctx$source(system.file("js/daff.js", package="daff"))
  ctx$source(system.file("js/util.js", package="daff"))
  ctx
}
