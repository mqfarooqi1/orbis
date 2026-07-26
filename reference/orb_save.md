# Save a plot at any resolution

Writes a plot to disk. The format is taken from the file extension:

## Usage

``` r
orb_save(plot, file, width = 820, height = 520, dpi = 300, interactive = TRUE)
```

## Arguments

- plot:

  An `orb_spec` object.

- file:

  Output path. The extension selects the format.

- width, height:

  Logical size in pixels (the drawing is laid out at this size, then
  rendered at `dpi`).

- dpi:

  Resolution for raster formats. 96 is screen resolution; 300 is a
  common print requirement; 600 gives very high resolution output.

- interactive:

  For `.html` and `.svg`, embed interactive behaviour.

## Value

The file path, invisibly.

## Details

- `.svg`:

  Vector output from the built-in SVG writer. Being a vector format it
  is resolution independent - it stays sharp at any size.

- `.html`:

  A self-contained interactive page (see
  [`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md)).

- `.pdf`:

  Vector output through R's PDF device.

- `.png`, `.tiff`, `.jpeg`:

  Raster output at the requested `dpi`; use 300 or more for print.

## See also

[`orb_svg()`](https://mqfarooqi1.github.io/orbis/reference/orb_svg.md),
[`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md),
[`orb_draw()`](https://mqfarooqi1.github.io/orbis/reference/orb_draw.md)

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
f <- tempfile(fileext = ".png")
orb_save(p, f, dpi = 300)
file.exists(f)
#> [1] TRUE
unlink(f)
```
