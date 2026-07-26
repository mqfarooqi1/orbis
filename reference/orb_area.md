# Area layer

Fills the region between a line and a baseline.

## Usage

``` r
orb_area(
  ...,
  data = NULL,
  fill = NULL,
  alpha = 0.45,
  baseline = 0,
  smooth = FALSE
)
```

## Arguments

- ...:

  Aesthetic mappings for this layer only, as `channel = column`.

- data:

  Optional data frame overriding the plot data.

- fill:

  Fixed fill used when the `fill` channel is not mapped.

- alpha:

  Opacity between 0 and 1.

- baseline:

  Value the area is filled down to (default 0).

- smooth:

  Draw a smoothed upper boundary. Default `FALSE`.

## Value

An object of class `orb_layer`.

## Examples

``` r
df <- data.frame(t = 1:40, v = abs(cumsum(rnorm(40))))
orb(df, x = t, y = v) + orb_area(alpha = 0.5) + orb_line()
#> <orb_spec>
#>   data:   40 rows x 2 columns
#>   mapping: x, y 
#>   layers:  area + line 
```
