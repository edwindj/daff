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
    csv <- ctx$call("to_csv", I(var_name))
    gsub("\r", "", csv) # remove those \r's
  }

  from_csv <- function(txt){
    ctx$assign(var_name, txt)
    ctx$assign(var_name, I(paste0("from_csv(",var_name,")")))
  }

  if (!missing(df)){
    set_data(df)
  }

  structure( list( set_data=set_data
                 , get_data=get_data
                 , var_name=var_name
                 , raw=raw
                 , to_csv=to_csv
                 , from_csv=from_csv
                 , ctx=ctx
                 )
             , class="TableView"
  )
}

#' @export
print.TableView <- function(x, ...){
  txt <- x$get_data()
  print(txt)
  invisible(txt)
}

write_diff <- function(diff, con){
  stopifnot(inherits(diff, "TableView"))
  writeLines(diff$to_csv(), con)
}

read_diff <- function(con){
  ctx <- get_context()
  diff <- TableView(ctx)
  txt <- paste0(readLines(con), collapse = "\n")
  diff$from_csv(txt)
  diff
}
