ctx <- NULL

get_context <- function(){
  if (is.null(ctx)){
    ctx <<- V8::new_context("window")
    ctx$source(system.file("js/underscore.js", package="V8"))
    ctx$source(system.file("js/daff.js", package="daff"))
    ctx$source(system.file("js/util.js", package="daff"))
  }
  ctx
}
