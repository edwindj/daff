TableView <- function(ctx, df, var_name){
  if (missing(var_name)){
    var_name <- ctx$get(I("_.uniqueId('tv')"))
  }

  set_data <- function(df){
    ctx$assign(var_name, df)
    ctx$assign(var_name, I(paste0("to_table_view(",var_name,")")))
  }

  get_data <- function(){
    ctx$get(I(paste0("to_objects(",var_name,".data)")))
  }

  raw <- function(){
    ctx$get(var_name)
  }

  to_csv <- function(){
    ctx$call("to_csv", I(var_name))
  }

  if (!missing(df)){
    set_data(df)
  }

  structure( list(set_data=set_data, get_data=get_data, var_name=var_name, raw=raw, to_csv=to_csv)
             , class="TableView"
  )
}

#' @export
print.TableView <- function(x, ...){
  txt <- x$get_data()
  print(txt)
  invisible(txt)
}
