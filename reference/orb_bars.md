# Bar layer

Draws one bar per observation. `x` may be discrete (a factor or
character column) or continuous. Bars start at zero.

## Usage

``` r
orb_bars(
  ...,
  data = NULL,
  width = 0.72,
  fill = NULL,
  colour = NULL,
  alpha = 0.95,
  horizontal = FALSE
)
```

## Arguments

- ...:

  Aesthetic mappings for this layer only, as `channel = column`.

- data:

  Optional data frame overriding the plot data.

- width:

  Bar width as a fraction of the available slot (0-1).

- fill:

  Fixed fill used when the `fill` channel is not mapped.

- colour:

  Fixed colour used when the `colour` channel is not mapped.

- alpha:

  Opacity between 0 and 1.

- horizontal:

  Draw horizontal bars. Default `FALSE`.

## Value

An object of class `orb_layer`.

## Examples

``` r
df <- data.frame(g = c("a", "b", "c"), v = c(3, 7, 5))
orb(df, x = g, y = v, fill = g) + orb_bars()
#> <orb_spec>
#>   data:   3 rows x 2 columns
#>   mapping: x, y, fill 
#>   layers:  bars 
```
