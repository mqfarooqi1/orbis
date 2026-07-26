# Line layer

Connects observations in the order they appear, optionally split by a
`group` or `colour` mapping.

## Usage

``` r
orb_line(
  ...,
  data = NULL,
  width = 1.8,
  colour = NULL,
  alpha = 1,
  smooth = FALSE
)
```

## Arguments

- ...:

  Aesthetic mappings for this layer only, as `channel = column`.

- data:

  Optional data frame overriding the plot data.

- width:

  Line width in pixels.

- colour:

  Fixed colour used when the `colour` channel is not mapped.

- alpha:

  Opacity between 0 and 1.

- smooth:

  Draw a smoothed curve through the points instead of straight segments
  (a Catmull-Rom style spline). Default `FALSE`.

## Value

An object of class `orb_layer`.

## Examples

``` r
df <- data.frame(t = 1:50, v = cumsum(rnorm(50)))
orb(df, x = t, y = v) + orb_line(width = 2, smooth = TRUE)
#> <orb_spec>
#>   data:   50 rows x 2 columns
#>   mapping: x, y 
#>   layers:  line 
```
