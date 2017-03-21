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
#'     to true, and - frankly - you should leave it at true for now.
#' @param always_show_order  \code{logical}
#'     Diffs for tables where row/column order has been permuted may include
#'     an extra row/column specifying the changes in row numbers.
#'     If you'd like that extra row/column to always be included,
#'     turn on this flag, and turn off never_show_order.
#' @param columns_to_ignore \code{character}
#'     List of columns to ignore in all calculations.  Changes
#'     related to these columns should be discounted.
#' @param count_like_a_spreadsheet \code{logical}
#'     Should column numbers, if present, be rendered spreadsheet-style
#'     as A,B,C,...,AA,BB,CC?  Defaults to true.
#' @param ids \code{charcter}
#'     List of columns that make up a primary key, if known. Otherwise heuristics are used to find a decent key (or a set of decent keys). Please set via (multiple calls of) addPrimaryKey(). This variable will be made private soon.
#' @param ignore_whitespace \code{logical}
#'     Should whitespace be omitted from comparisons.  Defaults to false.
#' @param never_show_order \code{logical}
#'     Diffs for tables where row/column order has been permuted may include
#'     an extra row/column specifying the changes in row numbers.
#'     If you'd like to be sure that that row/column is *never
#'     included, turn on this flag, and turn off always_show_order.
#' @param ordered \code{logical}
#'     Is the order of rows and columns meaningful? Defaults to `true`.
#' @param padding_strategy \code{logical}
#'     Strategy to use when padding columns.  Valid values are "smart", "dense",
#'     and "sparse".  Leave null for a sensible default.
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
#'     on index/key columns needed to identify rows to be included
#'     in the diff.
#' @param show_unchanged_meta \code{logical}
#'     Show all column properties, if available, even if unchanged.
#'     Defaults to false.
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
                      always_show_order        = NULL,
                      columns_to_ignore        = NULL,
                      count_like_a_spreadsheet = TRUE,
                      ids                      = NULL,
                      ignore_whitespace        = FALSE,
                      never_show_order         = NULL,
                      ordered                  = TRUE,
                      padding_strategy         = NULL,
                      show_unchanged           = FALSE, # rows
                      show_unchanged_columns   = FALSE,
                      unchanged_column_context = 1L,
                      unchanged_context        = 1L,     # rows
                      new                      = FALSE
                      ){
  ctx     <- get_context()
  tv      <- TableView(ctx, data)
  tv_ref  <- TableView(ctx, data_ref)
  tv_diff <- TableView(ctx)

  # add target classes to diff
  tv_diff$mode      <- sapply(data, storage.mode)
  tv_diff$is_factor <- sapply(data, is.factor)
  tv_diff$levels    <- lapply(data, levels)

  # create object to hold options, named 'cf' in ctx *and* in R
  cf <- ctx$eval("cf = new daff.CompareFlags();")

  to.null <- function(x) if(is.null(x)) "null" else x

  # add scalar options
  cf["always_show_header"       ] <- to.null( always_show_header       )
  cf["always_show_order"        ] <- to.null( always_show_order        )
  cf["count_like_a_spreadsheet" ] <- to.null( count_like_a_spreadsheet )
  cf["ignore_whitespace"        ] <- to.null( ignore_whitespace        )
  cf["never_show_order"         ] <- to.null( never_show_order         )
  cf["ordered"                  ] <- to.null( ordered                  )
  cf["padding_strategy"         ] <- to.null( padding_strategy         )
  cf["show_unchanged"           ] <- to.null( show_unchanged           )
  cf["show_unchanged_columns"   ] <- to.null( show_unchanged_columns   )
  cf["unchanged_column_context" ] <- to.null( unchanged_column_context )

  # add vector options
  lapply(ids,               function(val) ctx$call("cf.addPrimaryKey", val))
  lapply(columns_to_ignore, function(val) ctx$call("cf.ignoreColumn",  val))

  diff <- paste0("diff(",tv_ref$var_name,",",tv$var_name,", cf)")
  ctx$assign(tv_diff$var_name, JS(diff))

  class(tv_diff) <- c("data_diff", class(tv_diff))

  # store names of the compared objects for later use by render_diff
  names <- list("data_ref" = deparse(substitute(data_ref)),
                "data"     = deparse(substitute(data    ))
  )
  attr(tv_diff, "data_names") <- names

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
