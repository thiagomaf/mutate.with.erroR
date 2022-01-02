
# mutate.with.erroR

<!-- badges: start -->
<!-- badges: end -->

The goal of `{mutate.with.erroR}` is to create a public repository for maintaining the publicly available `mutate_with_error()` function. `mutate_with_error()` is based on the widely known `mutate()` and was first published in [HERE]. It mutate `numeric` columns doing mathematical calculations as instructed by the user, create an expression describing the Gaussian error propagation calculation and returns both values (i.e. the estimate `X` and the propagated error `dX`). All columns used in a calculation should be provided with an associated error measure (in general `standard error`).

Normally this function is used to do mathematical calculations between  average values of variables with associated errors. For example, when one wants to calculate the speed of an object, one measures the distance (`S`) that the object moved (which has an error; e.g. graduation on the ruler) and the time (`T`) it took to move along this distance (this also has an error; e.g. only measure down to seconds). The speed calculated as `S/T` will also have an associated error which reflects the combined errors of `S` and `T`. Gaussian error propagation uses calculus to achieve this propagated error estimation.

## Installation

You can install the development version of `{mutate.with.erroR}` like so:

``` r
install.packages("devtools")
devtools::install_github("thiagomaf/mutate.with.erroR")
```

## Example

Below we create a `data.frame` with two variables `A` and `B` (representing the mean of the `disp` and `hp` columns of the `mtcars` dataset) and their respective standard errors `dA` and `dB` (i.e. `sd(x)/sqrt(length(x))`). The prefix 'd' is used to indicate the error measures associated to any given variable. `mutate_with_error()` is used as `mutate()` - calculations are indicated as unquoted expressions and are separated by comma. `mutate_with_error()` will return the estimates calculated and their errors.

``` r
mtcars %>%
  with({
    data.frame(
      A  = mean(disp, na.rm = TRUE),
      dA =   sd(disp, na.rm = TRUE)/sqrt(length(disp)),
      B  = mean(hp, na.rm = TRUE),
      dB =   sd(hp, na.rm = TRUE)/sqrt(length(hp))
    )
  }) %>%
  mutate_with_error(C = A + B, D = A / B)
```
---------------------------------------------------------------
   A      dA       B      dB       C      dC       D      dD   
------- ------- ------- ------- ------- ------- ------- -------
 230.7   21.91   146.7   12.12   377.4   25.04   1.573   0.198 
---------------------------------------------------------------
"# mutate.with.erroR" 
