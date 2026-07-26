# Point layer positioned by longitude and latitude

Places points on a map using the active projection. Use inside a plot
that also has an
[`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md)
layer, mapping `x` to longitude and `y` to latitude.

## Usage

``` r
orb_geo_points(
  ...,
  data = NULL,
  size = 4,
  colour = "#F76707",
  alpha = 0.9,
  stroke = 0.8
)
```

## Arguments

- ...:

  Aesthetic mappings for this layer only, as `channel = column`.

- data:

  Optional data frame overriding the plot data.

- size:

  Point radius in pixels when `size` is not mapped (default 3.2).

- colour:

  Fixed colour used when the `colour` channel is not mapped.

- alpha:

  Opacity between 0 and 1.

- stroke:

  Outline width in pixels.

## Value

An object of class `orb_layer`.

## Examples

``` r
cities <- data.frame(long = c(2.35, -74, 151.2), lat = c(48.86, 40.7, -33.87),
                     pop = c(11, 19, 5))
orb(cities, x = long, y = lat, size = pop) +
  orb_map() + orb_points(colour = "#F76707") + orb_coord_map("robinson")
#> <orb_spec>
#>   data:   3 rows x 3 columns
#>   mapping: x, y, size 
#>   layers:  map + points 
```
