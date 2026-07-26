# Visual themes

Themes control the non-data appearance of a plot: colours of the
background, grid, axes and text, plus base font size. Add a theme to a
plot with `+`.

## Usage

``` r
orb_theme_light(base_size = 12, ...)

orb_theme_dark(base_size = 12, ...)

orb_theme_minimal(base_size = 12, ...)

orb_theme_ink(base_size = 12, ...)
```

## Arguments

- base_size:

  Base font size in points (default 12).

- ...:

  Named theme elements to override, for example `panel = "#111111"` or
  `grid = "#333333"`. Recognised elements are `bg`, `panel`, `grid`,
  `axis`, `text`, `title`, `accent`, `base_size` and `font`.

## Value

An object of class `orb_theme`, to be added to a plot.

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg) + orb_points()
p + orb_theme_dark()
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 

p + orb_theme_light(base_size = 14)
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 
```
