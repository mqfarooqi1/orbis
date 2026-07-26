# Draw a plot on the current graphics device

Renders through R's grid graphics, so the plot appears on whatever
device is active.
[`orb_save()`](https://mqfarooqi1.github.io/orbis/reference/orb_save.md)
is usually more convenient.

## Usage

``` r
orb_draw(plot, width = 820, height = 520)
```

## Arguments

- plot:

  An `orb_spec` object.

- width, height:

  Logical size in pixels.

## Value

`NULL`, invisibly. Called for its side effect.

## Examples

``` r
p <- orb(mtcars, x = wt, y = mpg) + orb_points()
f <- tempfile(fileext = ".png")
grDevices::png(f, width = 820, height = 520)
orb_draw(p)
grDevices::dev.off()
#> agg_record_197362be5909 
#>                       2 
unlink(f)
```
