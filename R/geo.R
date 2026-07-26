#' Map projections
#'
#' Sets the coordinate system to a geographic projection. Longitude and
#' latitude are projected before being mapped to the panel, so map layers and
#' point layers stay aligned.
#'
#' Available projections:
#'
#' \describe{
#'   \item{`equirectangular`}{Longitude and latitude used directly; simple and
#'     fast, but distorts area away from the equator.}
#'   \item{`mercator`}{Conformal cylindrical projection; preserves angles,
#'     greatly exaggerates high latitudes. Latitudes are clipped at
#'     \eqn{\pm}`max_lat`.}
#'   \item{`robinson`}{A compromise projection widely used for world maps.}
#'   \item{`mollweide`}{Equal-area pseudo-cylindrical projection.}
#'   \item{`orthographic`}{A view of the globe from infinite distance, centred
#'     on `centre`; the hemisphere facing away from the viewer is hidden.}
#' }
#'
#' @param projection Projection name (see Details).
#' @param centre Length-2 numeric vector, `c(longitude, latitude)`, giving the
#'   centre of an orthographic view.
#' @param max_lat Latitude at which the Mercator projection is clipped.
#' @return An object of class `orb_coord`, to be added to a plot.
#' @references Snyder, J. P. (1987) "Map Projections: A Working Manual."
#'   US Geological Survey Professional Paper 1395. \doi{10.3133/pp1395}
#' @examples
#' orb_worldmap() + orb_coord_map("robinson")
#' orb_worldmap() + orb_coord_map("orthographic", centre = c(20, 15))
#' @export
orb_coord_map <- function(projection = "equirectangular", centre = c(0, 0),
                          max_lat = 84) {
  projection <- match.arg(projection,
    c("equirectangular", "mercator", "robinson", "mollweide", "orthographic"))
  structure(list(type = "map", projection = projection, centre = centre,
                 max_lat = max_lat), class = "orb_coord")
}

#' Cartesian coordinates
#'
#' The default coordinate system. Use it to return to Cartesian coordinates or
#' to force a fixed aspect ratio.
#'
#' @param ratio Data units per y unit relative to x, or `NULL` for free.
#' @return An object of class `orb_coord`.
#' @examples
#' orb(mtcars, x = wt, y = mpg) + orb_points() + orb_coord_cartesian()
#' @export
orb_coord_cartesian <- function(ratio = NULL) {
  structure(list(type = "cartesian", ratio = ratio), class = "orb_coord")
}

## Radius of the globe in projected units (degrees-equivalent), used to clamp
## polygons to the limb in the orthographic projection.
#' @keywords internal
#' @noRd
.globe_r <- 57.29577951

## Project longitude/latitude to planar coordinates. Returns a list with x, y
## and `visible` (FALSE for points hidden on the far side of a globe).
#' @keywords internal
#' @noRd
.project <- function(long, lat, coord) {
  proj <- coord$projection %||% "equirectangular"
  d2r <- pi / 180
  lam <- long * d2r
  phi <- lat * d2r
  vis <- rep(TRUE, length(long))

  if (proj == "equirectangular") {
    x <- long; y <- lat
  } else if (proj == "mercator") {
    ml <- (coord$max_lat %||% 84)
    phi2 <- pmin(pmax(lat, -ml), ml) * d2r
    x <- long
    y <- log(tan(pi / 4 + phi2 / 2)) / d2r
  } else if (proj == "robinson") {
    # Robinson: tabulated coefficients, interpolated (Snyder 1987)
    lt <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90)
    AA <- c(1.0000, 0.9986, 0.9954, 0.9900, 0.9822, 0.9730, 0.9600, 0.9427,
            0.9216, 0.8962, 0.8679, 0.8350, 0.7986, 0.7597, 0.7186, 0.6732,
            0.6213, 0.5722, 0.5322)
    BB <- c(0.0000, 0.0620, 0.1240, 0.1860, 0.2480, 0.3100, 0.3720, 0.4340,
            0.4958, 0.5571, 0.6176, 0.6769, 0.7346, 0.7903, 0.8435, 0.8936,
            0.9394, 0.9761, 1.0000)
    ab <- abs(lat)
    A <- stats::approx(lt, AA, xout = pmin(ab, 90), rule = 2)$y
    B <- stats::approx(lt, BB, xout = pmin(ab, 90), rule = 2)$y
    x <- 0.8487 * A * long
    y <- 1.3523 * B * sign(lat) * 57.29577951
  } else if (proj == "mollweide") {
    th <- phi
    for (i in 1:8) {
      dth <- -(2 * th + sin(2 * th) - pi * sin(phi)) / (2 + 2 * cos(2 * th))
      th <- th + dth
    }
    x <- (2 * sqrt(2) / pi) * lam * cos(th) * 57.29577951
    y <- sqrt(2) * sin(th) * 57.29577951
  } else { # orthographic
    c0 <- (coord$centre %||% c(0, 0))
    l0 <- c0[1] * d2r; p0 <- c0[2] * d2r
    cosc <- sin(p0) * sin(phi) + cos(p0) * cos(phi) * cos(lam - l0)
    vis <- cosc >= 0
    x <- cos(phi) * sin(lam - l0) * 57.29577951
    y <- (cos(p0) * sin(phi) - sin(p0) * cos(phi) * cos(lam - l0)) * 57.29577951
  }
  list(x = x, y = y, visible = vis)
}
