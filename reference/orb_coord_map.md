# Map projections

Sets the coordinate system to a geographic projection. Longitude and
latitude are projected before being mapped to the panel, so map layers
and point layers stay aligned.

## Usage

``` r
orb_coord_map(projection = "equirectangular", centre = c(0, 0), max_lat = 84)
```

## Arguments

- projection:

  Projection name (see Details).

- centre:

  Length-2 numeric vector, `c(longitude, latitude)`, giving the centre
  of an orthographic view.

- max_lat:

  Latitude at which the Mercator projection is clipped.

## Value

An object of class `orb_coord`, to be added to a plot.

## Details

Available projections:

- `equirectangular`:

  Longitude and latitude used directly; simple and fast, but distorts
  area away from the equator.

- `mercator`:

  Conformal cylindrical projection; preserves angles, greatly
  exaggerates high latitudes. Latitudes are clipped at \\\pm\\`max_lat`.

- `robinson`:

  A compromise projection widely used for world maps.

- `mollweide`:

  Equal-area pseudo-cylindrical projection.

- `equalearth`:

  The Equal Earth projection of Savric, Patterson and Jenny (2019):
  equal-area, like Mollweide, but with continents shaped much closer to
  the familiar Robinson outline. A good modern default for thematic
  world maps, because areas are not distorted.

- `orthographic`:

  A view of the globe from infinite distance, centred on `centre`; the
  hemisphere facing away from the viewer is hidden.

## References

Snyder, J. P. (1987) "Map Projections: A Working Manual." US Geological
Survey Professional Paper 1395.
[doi:10.3133/pp1395](https://doi.org/10.3133/pp1395)

Savric, B., Patterson, T. & Jenny, B. (2019) "The Equal Earth map
projection." International Journal of Geographical Information Science
33, 454-465.
[doi:10.1080/13658816.2018.1504949](https://doi.org/10.1080/13658816.2018.1504949)

## Examples

``` r
orb_worldmap() + orb_coord_map("robinson")
#> <orb_spec>
#>   data:   26953 rows x 4 columns
#>   mapping:  
#>   layers:  map 

orb_worldmap() + orb_coord_map("equalearth")
#> <orb_spec>
#>   data:   26953 rows x 4 columns
#>   mapping:  
#>   layers:  map 

orb_worldmap() + orb_coord_map("orthographic", centre = c(20, 15))
#> <orb_spec>
#>   data:   26953 rows x 4 columns
#>   mapping:  
#>   layers:  map 
```
