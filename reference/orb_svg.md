# Render a plot as SVG

Produces a standalone SVG image of a plot. SVG is a vector format, so
the result is resolution independent: it stays sharp at any size or zoom
level, which is what makes it suitable both for the web and for print.

## Usage

``` r
orb_svg(plot, width = 820, height = 520, interactive = TRUE, id = NULL)
```

## Arguments

- plot:

  An `orb_spec` object.

- width, height:

  Size in pixels.

- interactive:

  Embed JavaScript for tooltips, hover highlighting, zoom, pan and
  legend toggling. Set `FALSE` for a static image, for example when
  embedding in a document that forbids scripts.

- id:

  Element id used by the embedded script; generated if `NULL`.

## Value

A character string containing SVG (and, if requested, a wrapping `div`
with the script).

## See also

[`orb_save()`](https://mqfarooqi1.github.io/orbis/reference/orb_save.md),
[`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md)

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg) + orb_points()
s <- orb_svg(p, interactive = FALSE)
substr(s, 1, 40)
#> [1] "<svg xmlns=\"http://www.w3.org/2000/svg\" "
```
