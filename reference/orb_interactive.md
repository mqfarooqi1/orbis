# Open or write an interactive plot

Builds a self-contained HTML document containing the plot as inline SVG
plus a small embedded script. The result works offline, needs no
JavaScript library, and supports tooltips, hover highlighting,
mouse-wheel zoom, dragging to pan, double-click to reset, and clicking
legend keys to show or hide series.

## Usage

``` r
orb_interactive(
  plot,
  file = NULL,
  width = 820,
  height = 520,
  title = "orbis plot"
)
```

## Arguments

- plot:

  An `orb_spec` object.

- file:

  Optional output path. If `NULL`, an object suitable for the RStudio
  viewer or an R Markdown document is returned instead.

- width, height:

  Size in pixels.

- title:

  Title of the HTML document.

## Value

If `file` is given, the path (invisibly); otherwise an `htmltools` tag
object.

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
f <- tempfile(fileext = ".html")
orb_interactive(p, file = f)
file.exists(f)
#> [1] TRUE
unlink(f)
```
