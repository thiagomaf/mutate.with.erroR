#' Create, (delete) and modify numeric columns with Gaussian error propagation
#'
#' `mutate()` adds new variables and preserves existing ones. New variables
#' overwrite existing variables of the same name.
#' Variables can be removed by setting their value to `NULL`.
#'
#' @param .data A data frame, data frame extension (e.g. a tibble), or a
#'   lazy data frame (e.g. from dbplyr or dtplyr).
#' @param ... Name-value pairs. The name gives the name of the column in the
#'   output.
#' @param echo .
#'
#' @importFrom dplyr mutate
#' @importFrom plyr llply .
#' @importFrom purrr map_chr
#' @importFrom rlang enexprs
#' @importFrom stats D setNames
#' @importFrom stringr str_c
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
#'   #mutate_with_error(C = A + B, D = A / B)
#'   mutate_with_error(
#'     C = A + B,
#'     D ~ A / B,
#'     "E = A + B",
#'     "G ~ A / B",
#'     as.formula("H ~ A / B")
#'   )
mutate_with_error <- function(.data, ..., echo = FALSE) {
  # captures variable names and calculation expression without evaluation
  .input_exprs <- rlang::enexprs(...)
  
  # work the names of each entry; robust to 4 diff kinds of inputs; see examples
  .input_names <- names(.input_exprs)
  
  .temp_exprs <- .input_exprs %>% # name == "" need working out
    purrr::map(.f = (function(.each_element) {
      .each_element %>% 
        deparse() %>%
        check_input_str()
      })) %>%
    rlang::set_names( # this should become a function
      purrr::map2_chr(
        .x = .,
        .y = names(.),
        .f = (function(.each_expr, .each_name) {
          dplyr::if_else(
            condition = .each_name == "",
            true      = .each_expr %>%
              stringr::str_split(pattern = "=") %>%
              purrr::map(1) %>%
              unlist(),
            false     = .each_name
          )
        })
      ) %>%
        as.character()
    ) %>%
    purrr::map(.f = stringr::str_remove, pattern = "(.*)=")

  .output_exprs <- append(
    .temp_exprs,     # user input expression
    .temp_exprs %>%  # error propagation expression
      purrr::map(.f = (function(.each_expr) {
        .each_expr <- .each_expr %>%
          str2expression()
        
        .each_expr %>% 
          all.vars() %>%
          purrr::map_chr(
            ~ sprintf('(d%s*(%s))^2', ., deparse(D(.each_expr, .)))
          ) %>%
          stringr::str_c(collapse = '+') %>%
          sprintf('sqrt(%s)', .)
      })) %>% 
      setNames(paste0("d", names(.temp_exprs)))
  ) %>% 
    purrr::map(.f = str2lang)
  
  # reorder Var, dVar for all Vars.
  .reorder_index <- outer(c("", "d"), names(.temp_exprs),  paste, sep="")
  .output_exprs <- .output_exprs[.reorder_index]
  
  if(echo) .output_exprs %>% print() # This can be the ECHO I was plannin

  # bang!bang!bang! mutate!
  .data %>% dplyr::mutate(!!! .output_exprs)
}