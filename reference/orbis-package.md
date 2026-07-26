# orbis: interactive and high-resolution layered graphics

orbis builds plots from a layered grammar, compiles them to a
resolution-independent scene description, and renders that scene through
two back-ends:

## Details

- a self-contained SVG writer with embedded JavaScript, giving
  interactive figures (tooltips, hover highlighting, zoom, pan, legend
  toggling) that need no internet connection and no JavaScript library,
  and

- R's own graphics devices, giving publication-quality raster or vector
  output at any resolution.

Geographic layers are first class: a simplified world polygon dataset
ships with the package
([world_map](https://mqfarooqi1.github.io/orbis/reference/world_map.md))
and can be drawn in several projections with
[`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md),
including an orthographic globe.

## Getting started

Start a plot with
[`orb()`](https://mqfarooqi1.github.io/orbis/reference/orb.md), add
layers with
[`orb_points()`](https://mqfarooqi1.github.io/orbis/reference/orb_points.md),
[`orb_line()`](https://mqfarooqi1.github.io/orbis/reference/orb_line.md),
[`orb_bars()`](https://mqfarooqi1.github.io/orbis/reference/orb_bars.md),
[`orb_area()`](https://mqfarooqi1.github.io/orbis/reference/orb_area.md)
or
[`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md),
adjust appearance with
[`orb_labs()`](https://mqfarooqi1.github.io/orbis/reference/orb_labs.md)
and the `orb_theme_*()` functions, then display it, write it with
[`orb_save()`](https://mqfarooqi1.github.io/orbis/reference/orb_save.md),
or open the interactive version with
[`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md).

## See also

Useful links:

- <https://github.com/mqfarooqi1/orbis>

- Report bugs at <https://github.com/mqfarooqi1/orbis/issues>

## Author

**Maintainer**: Muhammad Farooqi <mqfarooqi@gmail.com>

Authors:

- Muhammad Farooqi <mqfarooqi@gmail.com>
