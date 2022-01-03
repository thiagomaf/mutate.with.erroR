test_that(
  desc = "check_input_str()",
  code = {
    check_input_str('as.formula("G ~ A / B")') %>% expect_equal("G=A / B")
    check_input_str('as.formula(G ~ A / B)')   %>% expect_equal("G=A / B")
    check_input_str('list("G ~ A / B")')       %>% expect_equal("G=A / B")
    check_input_str('list(G ~ A / B)')         %>% expect_equal("G=A / B")
    check_input_str('G ~ A / B')               %>% expect_equal("G=A / B")
  }
)