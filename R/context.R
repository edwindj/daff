e <- new.env()

get_context <- function(){
  if (is.null(e$ctx)){
    e$ctx <<- V8::new_context("window")
    e$ctx$source(system.file("js/underscore.js", package="V8"))
    e$ctx$source(system.file("js/daff.js", package="daff"))
    e$ctx$source(system.file("js/util.js", package="daff"))
  }
  e$ctx
}
