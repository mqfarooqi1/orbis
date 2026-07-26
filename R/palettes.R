## Built-in colour palettes ---------------------------------------------------

#' @keywords internal
#' @noRd
.pal_stops <- list(
  # perceptually uniform sequential ramps
  viridis = c("#440154", "#414487", "#2A788E", "#22A884", "#7AD151", "#FDE725"),
  magma   = c("#000004", "#3B0F70", "#8C2981", "#DE4968", "#FE9F6D", "#FCFDBF"),
  mako    = c("#0B0405", "#357BA2", "#3497A9", "#4CC3AD", "#A5E3C4", "#DEF5E5"),
  ember   = c("#03051A", "#5B1A6B", "#B33C74", "#F06B51", "#F9B641", "#FCFFA4"),
  ice     = c("#08192B", "#154C79", "#2E82B8", "#63B7D9", "#A8DCEC", "#E8F6FB"),
  # diverging
  spectral = c("#3288BD", "#99D594", "#E6F598", "#FEE08B", "#FC8D59", "#D53E4F"),
  balance  = c("#2166AC", "#67A9CF", "#D1E5F0", "#FDDBC7", "#EF8A62", "#B2182B")
)

#' @keywords internal
#' @noRd
.pal_discrete <- list(
  orbis   = c("#4C6EF5", "#F76707", "#12B886", "#E64980", "#FAB005",
              "#7048E8", "#15AABF", "#82C91E", "#FA5252", "#495057"),
  vivid   = c("#E63946", "#F1FAEE", "#A8DADC", "#457B9D", "#1D3557"),
  earth   = c("#606C38", "#283618", "#DDA15E", "#BC6C25", "#FEFAE0"),
  neon    = c("#00F5D4", "#00BBF9", "#9B5DE5", "#F15BB5", "#FEE440")
)

#' Colour palettes available in orbis
#'
#' Lists the palette names accepted by [orb_scale_colour()] and
#' [orb_scale_fill()].
#'
#' @return A list with two character vectors: `continuous` (sequential and
#'   diverging ramps) and `discrete` (qualitative palettes).
#' @examples
#' orb_palettes()
#' @export
orb_palettes <- function() {
  list(continuous = names(.pal_stops), discrete = names(.pal_discrete))
}

## Interpolate a continuous palette at n points, or at supplied [0,1] values.
#' @keywords internal
#' @noRd
.ramp <- function(palette = "viridis", n = NULL, at = NULL) {
  stops <- .pal_stops[[palette]]
  if (is.null(stops)) {
    stops <- if (length(palette) > 1) palette else .pal_stops[["viridis"]]
  }
  f <- grDevices::colorRamp(stops, space = "Lab")
  if (is.null(at)) at <- seq(0, 1, length.out = n %||% 8)
  at[!is.finite(at)] <- 0
  at <- pmin(pmax(at, 0), 1)
  m <- f(at)
  grDevices::rgb(m[, 1], m[, 2], m[, 3], maxColorValue = 255)
}

## Pick n discrete colours, recycling if necessary.
#' @keywords internal
#' @noRd
.discrete_cols <- function(n, palette = "orbis") {
  p <- .pal_discrete[[palette]]
  if (is.null(p)) p <- if (length(palette) > 1) palette else .pal_discrete[["orbis"]]
  if (n <= length(p)) return(p[seq_len(n)])
  rep(p, length.out = n)
}
