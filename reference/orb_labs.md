# Axis, legend and plot labels

Axis, legend and plot labels

## Usage

``` r
orb_labs(
  title = NULL,
  subtitle = NULL,
  x = NULL,
  y = NULL,
  colour = NULL,
  fill = NULL,
  size = NULL,
  caption = NULL
)
```

## Arguments

- title:

  Plot title.

- subtitle:

  Plot subtitle.

- x, y:

  Axis titles.

- colour, fill, size:

  Legend titles for those channels.

- caption:

  Caption shown under the plot.

## Value

An object of class `orb_labs`, to be added to a plot.

## Examples

``` r
orb(mtcars, x = wt, y = mpg) + orb_points() +
  orb_labs(title = "Fuel use", x = "Weight", y = "Miles per gallon")
#> <orb_spec>
#>   data:   32 rows x 11 columns
#>   mapping: x, y 
#>   layers:  points 
```
