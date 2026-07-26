# Add layers, scales, labels and themes to a plot

The `+` operator assembles a plot from parts, in the tradition of a
layered grammar of graphics.

## Usage

``` r
# S3 method for class 'orb_spec'
e1 + e2
```

## Arguments

- e1:

  An `orb_spec` object.

- e2:

  A layer, scale, theme, labels or coordinate object to add.

## Value

An `orb_spec` object.

## Examples

``` r
orb(mtcars, x = wt, y = mpg) + orb_points() + orb_theme_dark()
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 
```
