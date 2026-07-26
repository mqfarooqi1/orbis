#' orbis: interactive and high-resolution layered graphics
#'
#' orbis builds plots from a layered grammar, compiles them to a
#' resolution-independent scene description, and renders that scene through
#' two back-ends:
#'
#' * a self-contained SVG writer with embedded JavaScript, giving interactive
#'   figures (tooltips, hover highlighting, zoom, pan, legend toggling) that
#'   need no internet connection and no JavaScript library, and
#' * R's own graphics devices, giving publication-quality raster or vector
#'   output at any resolution.
#'
#' Geographic layers are first class: a simplified world polygon dataset ships
#' with the package ([world_map]) and can be drawn in several projections with
#' [orb_map()], including an orthographic globe.
#'
#' @section Getting started:
#' Start a plot with [orb()], add layers with [orb_points()], [orb_line()],
#' [orb_bars()], [orb_area()] or [orb_map()], adjust appearance with
#' [orb_labs()] and the `orb_theme_*()` functions, then display it, write it
#' with [orb_save()], or open the interactive version with [orb_interactive()].
#'
#' @keywords internal
"_PACKAGE"
