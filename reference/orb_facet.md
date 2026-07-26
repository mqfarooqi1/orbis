# Split a plot into small multiples

Faceting draws one panel per level of a grouping variable, laid out in a
grid. Comparing many small panels that share a scale is often clearer
than overplotting every group in one panel.

## Usage

``` r
orb_facet(by, ncol = NULL, scales = c("fixed", "free_x", "free_y", "free"))
```

## Arguments

- by:

  Bare column name to facet by, for example `orb_facet(cyl)`.

- ncol:

  Number of columns in the grid. The default chooses a roughly square
  arrangement.

- scales:

  Whether panels share their axes: `"fixed"` (the default, so panels are
  directly comparable), `"free_x"`, `"free_y"` or `"free"`.

## Value

An object of class `orb_facet`, to be added to a plot.

## Examples

``` r
orb(mtcars, x = wt, y = mpg) + orb_points() + orb_facet(cyl)
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 

orb(mtcars, x = wt, y = mpg) + orb_points() +
  orb_facet(cyl, ncol = 3, scales = "free")
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 
```
