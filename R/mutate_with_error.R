#' Create, (delete) and modify numeric columns with Gaussian error propagation
#'
#' `mutate()` adds new variables and preserves existing ones. New variables
#' overwrite existing variables of the same name.
#' Variables can be removed by setting their value to `NULL`.
#'
#' @param .data A data frame, data frame extension (e.g. a tibble), or a
#'   lazy data frame (e.g. from dbplyr or dtplyr).
#' @param .arg Name-value pairs. The name gives the name of the column in the
#'   output.
#' @param ... Same as `.arg`
#'
#' @importFrom dplyr mutate
#' @importFrom plyr llply .
#' @importFrom rlang enexprs
#' @importFrom stats D setNames
#'
#' @export
#'
#' @return
#' An object of the same type as `.data`. The output has the following
#' properties:
#'
#' * For `mutate()`:
#'   * Columns from `.data` will be preserved according to the `.keep` argument.
#'   * Existing columns that are modified by `...` will always be returned in
#'     their original location.
#'   * New columns created through `...` will be placed according to the
#'     `.before` and `.after` arguments.
#'
#'
#' @examples
#' mtcars %>%
#'   with({
#'     data.frame(
#'       A  = mean(disp, na.rm = TRUE),
#'       dA =   sd(disp, na.rm = TRUE)/sqrt(length(disp)),
#'       B  = mean(hp, na.rm = TRUE),
#'       dB =   sd(hp, na.rm = TRUE)/sqrt(length(hp))
#'     )
#'   }) %>%
#'   mutate_with_error(C = A + B, D = A / B)
mutate_with_error <- function(.data, .arg, ...) {
  .user_exprs <- enexprs(.arg, ...)
  .user_exprs <- .user_exprs[-which(sapply(.user_exprs, class) != "call")]

  if("character" %in% sapply(.user_exprs, class)) {
    stop("mutate() arguments should not be string.")
  }

  .output_exprs <- .user_exprs %>%
    append(
      .user_exprs %>%
        llply(function(.each_expr) {
          .each_expr %>% all.vars() %>%
            sapply(function(v) {   # expression to compute new variable errors
              dfdp = deparse(D(.each_expr, v))
              sprintf('(d%s*(%s))^2', v, dfdp)
            }) %>%
            paste(collapse='+') %>%
            sprintf('sqrt(%s)', .) %>%
            str2lang()
        }) %>%
        setNames(paste0("d", names(.user_exprs)))
    )

  .reorder_index <- outer(c("", "d"), names(.user_exprs),  paste, sep="")
  .output_exprs <- .output_exprs[.reorder_index]

  .data %>% mutate(!!! .output_exprs)
}
# mutate_with_error <- function(.data, f) {
#   # require(dplyr)
#   #https://www.r-bloggers.com/easy-error-propagation-in-r/
#   exprs = list(
#     # expression to compute new variable values
#     deparse(f[[3]]),
#
#     # expression to compute new variable errors
#     sapply(all.vars(f[[3]]), function(v) {
#       dfdp = deparse(D(f[[3]], v))
#       sprintf('(d%s*(%s))^2', v, dfdp)
#     }) %>%
#       paste(collapse='+') %>%
#       sprintf('sqrt(%s)', .)
#   )
#   names(exprs) = c(
#     deparse(f[[2]]),
#     sprintf('d%s', deparse(f[[2]]))
#   )
#
#   #.data %>%
#   #  # the standard evaluation alternative of mutate()
#   #  mutate_(.dots=exprs) %>%
#   #  suppressWarnings()
#   .data[names(exprs)] <- lapply(exprs , function(x) {
#     eval(parse(text= x), envir = .data)
#   })
# }
