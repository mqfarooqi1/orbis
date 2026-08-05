# Changelog

## orbis 0.1.0

CRAN release: 2026-08-05

First release.

- A layered grammar
  ([`orb()`](https://mqfarooqi1.github.io/orbis/reference/orb.md) plus
  `+`) that compiles to a resolution-independent scene description,
  rendered either as interactive SVG or through R’s graphics devices at
  any resolution.
- Layers:
  [`orb_points()`](https://mqfarooqi1.github.io/orbis/reference/orb_points.md),
  [`orb_line()`](https://mqfarooqi1.github.io/orbis/reference/orb_line.md),
  [`orb_bars()`](https://mqfarooqi1.github.io/orbis/reference/orb_bars.md),
  [`orb_area()`](https://mqfarooqi1.github.io/orbis/reference/orb_area.md),
  [`orb_text()`](https://mqfarooqi1.github.io/orbis/reference/orb_text.md).
- Faceting with
  [`orb_facet()`](https://mqfarooqi1.github.io/orbis/reference/orb_facet.md),
  with shared or free scales.
- Geography built in:
  [`orb_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_map.md),
  [`orb_geo_points()`](https://mqfarooqi1.github.io/orbis/reference/orb_geo_points.md),
  [`orb_worldmap()`](https://mqfarooqi1.github.io/orbis/reference/orb_worldmap.md),
  the `world_map` dataset, and six projections via
  [`orb_coord_map()`](https://mqfarooqi1.github.io/orbis/reference/orb_coord_map.md),
  including the equal-area Equal Earth projection and an orthographic
  globe.
- Scales, four themes and perceptually uniform palettes.
- Output with
  [`orb_save()`](https://mqfarooqi1.github.io/orbis/reference/orb_save.md)
  (SVG, HTML, PDF, PNG, TIFF, JPEG),
  [`orb_svg()`](https://mqfarooqi1.github.io/orbis/reference/orb_svg.md),
  [`orb_interactive()`](https://mqfarooqi1.github.io/orbis/reference/orb_interactive.md)
  and
  [`orb_draw()`](https://mqfarooqi1.github.io/orbis/reference/orb_draw.md).
