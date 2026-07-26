# Text layer

Draws a text label at each observation.

## Usage

``` r
orb_text(..., data = NULL, size = 10, colour = NULL, dy = 0, alpha = 1)
```

## Arguments

- ...:

  Aesthetic mappings for this layer only, as `channel = column`.

- data:

  Optional data frame overriding the plot data.

- size:

  Font size in points.

- colour:

  Fixed colour used when the `colour` channel is not mapped.

- dy:

  Vertical offset in pixels (negative moves up).

- alpha:

  Opacity between 0 and 1.

## Value

An object of class `orb_layer`.

## Examples

``` r
df <- data.frame(x = 1:3, y = c(2, 4, 3), n = c("a", "b", "c"))
orb(df, x = x, y = y, label = n) + orb_points() + orb_text(dy = -10)
#> <orb_spec>
#>   data:   3 rows x 3 columns
#>   mapping: x, y, label 
#>   layers:  points + text 
```
