# orbis 0.1.0

First release.

* A layered grammar (`orb()` plus `+`) that compiles to a resolution-independent
  scene description, rendered either as interactive SVG or through R's graphics
  devices at any resolution.
* Layers: `orb_points()`, `orb_line()`, `orb_bars()`, `orb_area()`,
  `orb_text()`.
* Faceting with `orb_facet()`, with shared or free scales.
* Geography built in: `orb_map()`, `orb_geo_points()`, `orb_worldmap()`, the
  `world_map` dataset, and six projections via `orb_coord_map()`, including the equal-area
  Equal Earth projection and an orthographic globe.
* Scales, four themes and perceptually uniform palettes.
* Output with `orb_save()` (SVG, HTML, PDF, PNG, TIFF, JPEG), `orb_svg()`,
  `orb_interactive()` and `orb_draw()`.
