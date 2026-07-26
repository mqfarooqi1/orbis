# Cartesian coordinates

The default coordinate system. Use it to return to Cartesian coordinates
or to force a fixed aspect ratio.

## Usage

``` r
orb_coord_cartesian(ratio = NULL)
```

## Arguments

- ratio:

  Data units per y unit relative to x, or `NULL` for free.

## Value

An object of class `orb_coord`.

## Examples

``` r
orb(mtcars, x = wt, y = mpg) + orb_points() + orb_coord_cartesian()
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 
```
