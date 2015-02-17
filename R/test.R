
run <- function(x=iris){
  ctx <- V8::new_context("window")
  ctx$source("./inst/daff.js")
  ctx$source(system.file("js/underscore.js", package="V8"))
  ctx$source("./inst/util.js")
  ctx$call("to_table_view", x)
  ctx$assign("local", x)
  ctx$assign("local", I("to_table_view(local);"))
  ctx$get("local")
  #ctx$eval("to_objects(local.data)")
  ctx$get(I("to_objects(local.data)"))
}


to_table_view <- function(x, name, ctx){
  ctx$get(I("_.uniqueId.toString()"))
  ctx$assign(name, x)
  ttv <- paste0("to_table_view(",name,")")
  ctx$assign(name,I(ttv))
}

to_data_frame <- function(name, ctx){

}
#
#run()

TableView <- function(ctx, df, js_name){
  if (missing(js_name)){
    js_name <- ctx$get(I("_.uniqueId('tv')"))
  }
  structure(list(
    set_df = function(df){
      ctx$assign(js_name, df)
      ctx$assign(js_name, I(paste0("to_table_view(",js_name,")")))
    },
    get_df = function(){
      ctx$get(I(paste0("to_objects(",js_name,".data)")))
    }
    )
  , class="TableView")
}

tv <- TableView(ctx, iris)
tv$set_df(iris)
tv$get_df()
