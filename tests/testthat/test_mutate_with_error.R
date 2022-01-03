test_that(
  desc = "Sum of get_average_summary()",
  code = {
    .test_data <- mtcars %>%
      with({
        data.frame(
          A  = mean(disp, na.rm = TRUE),
          dA =   sd(disp, na.rm = TRUE)/sqrt(length(disp)),
          B  = mean(hp, na.rm = TRUE),
          dB =   sd(hp, na.rm = TRUE)/sqrt(length(hp))
        )
      }) %>%
      #mutate_with_error(C = A + B, D = A / B)
      mutate_with_error(
        C = A + B,
        D ~ A / B,
        "E = A + B",
        "G ~ A / B",
        as.formula("H ~ A / B")
      )
    
    .test_data$C  %>% round(digits = 4) %>% expect_equal(377.4094)
    .test_data$dC %>% round(digits = 4) %>% expect_equal( 25.0385)
    .test_data$D  %>% round(digits = 4) %>% expect_equal(  1.5729)
    .test_data$dD %>% round(digits = 4) %>% expect_equal(  0.1980)
    
    .test_data$E  %>% round(digits = 4) %>% expect_equal(377.4094)
    .test_data$dE %>% round(digits = 4) %>% expect_equal( 25.0385)
    .test_data$G  %>% round(digits = 4) %>% expect_equal(  1.5729)
    .test_data$dG %>% round(digits = 4) %>% expect_equal(  0.1980)
    .test_data$H  %>% round(digits = 4) %>% expect_equal(  1.5729)
    .test_data$dH %>% round(digits = 4) %>% expect_equal(  0.1980)
  }
)