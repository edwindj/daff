
run <- function(){
  ctx <- V8::new_context("window")
  ctx$source("./inst/daff.js")
  ctx$source(system.file("js/underscore.js", package="V8"))
  ctx$source("./inst/util.js")

  ctx$call("to_table_view", iris)
}

#
#run()
