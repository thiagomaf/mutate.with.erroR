#' check_input_str
#'
#' @param .str string
#'
#' @return
#' @export
#'
#' @return Prepared string (IMPROVE)
#'
#' @examples
#' check_input_str('as.formula("G ~ A / B")')
#' check_input_str('as.formula(G ~ A / B)')
#' check_input_str('list("G ~ A / B")')
#' check_input_str('list(G ~ A / B)')
#' check_input_str('G ~ A / B')
check_input_str <- function(.str) {
  dplyr::if_else(
    stringr::str_detect(string = .str, pattern = "as.formula\\((.*)\\)") |
      stringr::str_detect(string = .str, pattern = "list\\((.*)\\)"),
    true = {
      .str %>%
        stringr::str_match(pattern = "(.*)\\((.*)\\)") %>%
        magrittr::extract(3) # this is surely going to break!!!!
    },
    false = {
      .str
    }
  ) %>%
    stringr::str_replace_all(pattern = c('\"' = '')) %>%
    stringr::str_replace_all(pattern = c(' ~ ' = ' = ', ' = ' = '='))
}