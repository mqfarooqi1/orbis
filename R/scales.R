#' Scales
#'
#' Scales control how data values are converted to visual values: which colours
#' a variable spans, how large points become, and the limits and transformation
#' of the axes.
#'
#' @param palette Palette name (see [orb_palettes()]) or a character vector of
#'   colours to interpolate.
#' @param limits Numeric length-2 vector giving the data range to map, or
#'   `NULL` to use the observed range.
#' @param reverse Reverse the direction of the palette.
#' @param range Length-2 numeric vector giving the smallest and largest radius
#'   in pixels, for [orb_scale_size()].
#' @param trans Axis transformation: `"identity"` (default), `"log10"` or
#'   `"sqrt"`.
#' @param breaks Numeric vector of axis breaks, or `NULL` for automatic.
#' @param expand Fraction of the data range added as padding at each end.
#' @return An object of class `orb_scale`, to be added to a plot.
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg, colour = hp) + orb_points()
#' p + orb_scale_colour("magma", reverse = TRUE)
#' p + orb_scale_y(limits = c(10, 35))
#' @name orb_scale
NULL

#' @keywords internal
#' @noRd
.scale <- function(channel, ...) {
  structure(c(list(channel = channel), list(...)), class = "orb_scale")
}

#' @rdname orb_scale
#' @export
orb_scale_colour <- function(palette = "viridis", limits = NULL,
                             reverse = FALSE) {
  .scale("colour", palette = palette, limits = limits, reverse = reverse)
}

#' @rdname orb_scale
#' @export
orb_scale_fill <- function(palette = "viridis", limits = NULL,
                           reverse = FALSE) {
  .scale("fill", palette = palette, limits = limits, reverse = reverse)
}

#' @rdname orb_scale
#' @export
orb_scale_size <- function(range = c(2, 14), limits = NULL) {
  .scale("size", range = range, limits = limits)
}

#' @rdname orb_scale
#' @export
orb_scale_x <- function(limits = NULL, trans = "identity", breaks = NULL,
                        expand = 0.04) {
  .scale("x", limits = limits, trans = trans, breaks = breaks, expand = expand)
}

#' @rdname orb_scale
#' @export
orb_scale_y <- function(limits = NULL, trans = "identity", breaks = NULL,
                        expand = 0.04) {
  .scale("y", limits = limits, trans = trans, breaks = breaks, expand = expand)
}

#' @keywords internal
#' @noRd
.apply_trans <- function(v, trans) {
  switch(trans %||% "identity",
         log10 = { v[v <= 0] <- NA; log10(v) },
         sqrt  = { v[v < 0] <- NA; sqrt(v) },
         v)
}

#' @keywords internal
#' @noRd
.invert_trans <- function(v, trans) {
  switch(trans %||% "identity", log10 = 10^v, sqrt = v^2, v)
}
