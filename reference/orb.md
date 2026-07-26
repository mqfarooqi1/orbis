# Start a plot

`orb()` creates a plot specification: it records the data and the
mapping from variables to visual channels. Layers, labels, scales and
themes are added with `+`. Nothing is drawn until the plot is printed or
saved, so a specification is cheap to build and modify.

## Usage

``` r
orb(data, ...)
```

## Arguments

- data:

  A data frame.

- ...:

  Aesthetic mappings, given as `channel = column`.

## Value

An object of class `orb_spec`.

## Details

Mappings are given as bare column names, in the style of a formula-free
grammar: `orb(df, x = wt, y = mpg, colour = cyl)`. The recognised
channels are `x`, `y`, `colour` (or `color`), `fill`, `size`, `label`,
`group` and `tooltip`.

## See also

[`orb_points()`](https://mqfarooqi1.github.io/orbis/reference/orb_points.md),
[`orb_line()`](https://mqfarooqi1.github.io/orbis/reference/orb_line.md),
[`orb_bars()`](https://mqfarooqi1.github.io/orbis/reference/orb_bars.md),
[`orb_area()`](https://mqfarooqi1.github.io/orbis/reference/orb_area.md),
[`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md),
[`orb_save()`](https://mqfarooqi1.github.io/orbis/reference/orb_save.md),
[`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md)

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
p
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y, colour 
#>   layers:  points 
```
