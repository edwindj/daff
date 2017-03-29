#' Do a data diff
#'
#' Find differences with a reference data set. The diff can be used to \code{\link{patch_data}}, to store the difference
#' for documentation purposes using \code{\link{write_diff}} or to visualize the difference using \code{\link{render_diff}}
#'
#' @example ./examples/datadiff.R
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @param always_show_header \code{logical}
#'     Should we always give a table header in diffs? This defaults
#'     to TRUE, and - frankly - you should leave it at TRUE for now.
#' @param always_show_order  \code{logical}
#'     Diffs for tables where row/column order has been permuted may include
#'     an extra row/column specifying the changes in row/column numbers.
#'     If you'd like that extra row/column to always be included,
#'     turn on this flag, and turn off never_show_order.
#' @param columns_to_ignore \code{character}
#'     List of columns to ignore in all calculations.  Changes
#'     related to these columns should be discounted.
#' @param count_like_a_spreadsheet \code{logical}
#'     Should column numbers, if present, be rendered spreadsheet-style
#'     as A,B,C,...,AA,BB,CC?  Defaults to TRUE.
#' @param ids \code{charcter}
#'     List of columns that make up a primary key, if known. Otherwise heuristics are used to find a decent key (or a set of decent keys). Please set via (multiple calls of) addPrimaryKey(). This variable will be made private soon.
#' @param ignore_whitespace \code{logical}
#'     Should whitespace be omitted from comparisons.  Defaults to FALSE.
#' @param never_show_order \code{logical}
#'     Diffs for tables where row/column order has been permuted may include
#'     an extra row/column specifying the changes in row/column numbers.
#'     If you'd like to be sure that that row/column is *never
#'     included, turn on this flag, and turn off always_show_order.
#' @param ordered \code{logical}
#'     Is the order of rows and columns meaningful? Defaults to `TRUE`.
#' @param padding_strategy \code{logical}
#'     Strategy to use when padding columns.  Valid values are "auto",
#'     "smart", "dense", and "sparse".  Leave null for a sensible default.
#' @param show_meta \code{logical}
#'     Show changes in column properties, not just data, if available. Defaults to TRUE.
#' @param show_unchanged \code{logical}
#'     Should we show all rows in diffs?  We default to showing
#'     just rows that have changes (and some context rows around
#'     them, if row order is meaningful), but you can override
#'     this here.
#' @param show_unchanged_columns \code{logical}
#'     Should we show all columns in diffs?  We default to showing
#'     just columns that have changes (and some context columns around
#'     them, if column order is meaningful), but you can override
#'     this here.  Irrespective of this flag, you can rely
#'     on index/key columns needed to identify cols to be included
#'     in the diff.
#' @param show_unchanged_meta \code{logical}
#'     Show all column properties, if available, even if unchanged.
#'     Defaults to FALSE.
#' @param unchanged_column_context \code{integer}
#'     When showing context columns around a changed column, what
#'     is the minimum number of such columns we should show?
#' @param unchanged_context \code{integer}
#'     When showing context rows around a changed row, what
#'     is the minimum number of such rows we should show?
#'
#' @return difference object
#' @export
#' @seealso differs_from
diff_data <- function(data_ref,
                      data,
                      always_show_header       = TRUE,
                      always_show_order        = FALSE,
                      columns_to_ignore        = c(),
                      count_like_a_spreadsheet = TRUE,
                      ids                      = c(),
                      ignore_whitespace        = FALSE,
                      never_show_order         = FALSE,
                      ordered                  = TRUE,
                      padding_strategy         = c("auto", "smart", "dense", "sparse"),
                      show_meta                = TRUE,
                      show_unchanged           = FALSE, # rows
                      show_unchanged_columns   = FALSE,
                      show_unchanged_meta      = FALSE,
                      unchanged_column_context = 1L,
                      unchanged_context        = 1L     # rows
                      )
{
  padding_strategy <- match.arg(padding_strategy)
  if(padding_strategy=='auto') padding_strategy=NULL

  ctx     <- get_context()
  tv      <- TableView(ctx, data)
  tv_ref  <- TableView(ctx, data_ref)
  tv_diff <- TableView(ctx)

  # add target classes to diff
  tv_diff$mode      <- sapply(data, storage.mode)
  tv_diff$is_factor <- sapply(data, is.factor)
  tv_diff$levels    <- lapply(data, levels)

  # create object to hold options
  ctx$eval("cf = new daff.CompareFlags();")

  # add scalar options
  cf.assign <- function(name, x)
  {
    ctx$assign("__temp__", x)
    ctx$eval( JS(paste0("cf.", name, "=__temp__")) )
  }

  # add scalar options
  cf.assign("always_show_header",       always_show_header      )
  cf.assign("always_show_order",        always_show_order       ) #!
  cf.assign("count_like_a_spreadsheet", count_like_a_spreadsheet)
  cf.assign("ignore_whitespace",        ignore_whitespace       )
  cf.assign("never_show_order",         never_show_order        ) #!
  cf.assign("ordered",                  ordered                 )
  cf.assign("padding_strategy",         padding_strategy        ) #!
  cf.assign("show_meta",                show_meta               )
  cf.assign("show_unchanged",           show_unchanged          )
  cf.assign("show_unchanged_columns",   show_unchanged_columns  )
  cf.assign("show_unchanged_meta",      show_unchanged_meta     )
  cf.assign("unchanged_column_context", unchanged_column_context)
  cf.assign("unchanged_context",        unchanged_context       )

  # add vector options
  lapply(ids,               function(val) ctx$call("cf.addPrimaryKey", val) )
  lapply(columns_to_ignore, function(val) ctx$call("cf.ignoreColumn",  val) )

  # run the diff
  diff <- paste0("diff(",tv_ref$var_name,",",tv$var_name,", cf)")
  ctx$assign(tv_diff$var_name, JS(diff))
  class(tv_diff) <- c("data_diff", class(tv_diff))

  # Store summary and flag information for later
  summary <- ctx$get(JS(paste0(tv_diff$var_name, ".summary")))
  flags   <- ctx$get("cf")

  # names of the compared objects
  summary$source_name = deparse(substitute(data_ref))
  summary$target_name = deparse(substitute(data))

  # Textual description of changes to row and column counts
  if(summary$row_count_initial == summary$row_count_final)
    summary$row_count_change_text <- summary$row_count_initial
  else
    summary$row_count_change_text <- paste0(summary$row_count_initial, " --> ", summary$row_count_final)

  if(summary$col_count_initial == summary$col_count_final)
    summary$col_count_change_text <- summary$col_count_initial
  else
    summary$col_count_change_text <- paste0(summary$col_count_initial, " --> ", summary$col_count_final)


  attr(tv_diff, "summary") <- summary

  tv_diff
}

#' differs from,
#'
#' This is the same function as \code{\link{diff_data}} but with arguments
#' reversed. This is more useful when using \code{dplyr} and \code{magrittr}
#'
#' @param data \code{data.frame} to check for changes
#' @param data_ref \code{data.frame} reference data frame
#' @param ... not further specified
#' @return difference object
#' @export
#' @seealso diff_data
differs_from <- function(data, data_ref, ...){
  diff_data(data_ref=data_ref, data=data, ...)

}
