# A ready-made world map

A convenience wrapper that returns a complete world map plot, optionally
shaded by a value per region.

## Usage

``` r
orb_worldmap(
  values = NULL,
  region_col = "region",
  value_col = NULL,
  projection = "equirectangular",
  palette = "viridis",
  ocean = NULL,
  title = NULL
)
```

## Arguments

- values, region_col, value_col:

  Passed to
  [`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md)
  to build a choropleth.

- projection:

  Projection name; see
  [`orb_coord_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_coord_map.md).

- palette:

  Continuous palette name; see
  [`orb_palettes()`](https://mqfarooqi1.github.io/orbis/reference/orb_palettes.md).

- ocean:

  Optional sea colour; see
  [`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md).

- title:

  Optional plot title.

## Value

An `orb_spec` object.

## Examples

``` r
orb_worldmap(projection = "orthographic")
#> <orb_spec>
#>   data:   26953 rows x 4 columns
#>   mapping:  
#>   layers:  map 
```
