# Colour palettes available in orbis

Lists the palette names accepted by
[`orb_scale_colour()`](https://mqfarooqi1.github.io/orbis/reference/orb_scale.md)
and
[`orb_scale_fill()`](https://mqfarooqi1.github.io/orbis/reference/orb_scale.md).

## Usage

``` r
orb_palettes()
```

## Value

A list with two character vectors: `continuous` (sequential and
diverging ramps) and `discrete` (qualitative palettes).

## Examples

``` r
orb_palettes()
#> $continuous
#> [1] "viridis"  "magma"    "mako"     "ember"    "ice"      "spectral" "balance" 
#> 
#> $discrete
#> [1] "orbis" "vivid" "earth" "neon" 
#> 
```
