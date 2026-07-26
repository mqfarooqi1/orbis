#' World country polygons
#'
#' A simplified set of world country outlines, suitable for thematic world maps
#' at typical figure sizes. Polygon rings were simplified with the
#' Douglas-Peucker algorithm to keep the dataset small while preserving the
#' recognisable shape of coastlines and borders.
#'
#' Coordinates are unprojected longitude and latitude in degrees; use
#' [orb_coord_map()] to choose a projection.
#'
#' @format A data frame with four columns:
#' \describe{
#'   \item{long}{Longitude in degrees, from -180 to 180.}
#'   \item{lat}{Latitude in degrees, from -90 to 90.}
#'   \item{group}{Integer identifying the polygon ring a point belongs to.
#'     Points must be drawn ring by ring; a country made of several land masses
#'     has several rings.}
#'   \item{region}{Country or territory name.}
#' }
#' @source Derived from the world database of the \pkg{maps} package, whose
#'   boundaries come from Natural Earth (\url{https://www.naturalearthdata.com}),
#'   released into the public domain.
#' @references Douglas, D. H. & Peucker, T. K. (1973) "Algorithms for the
#'   reduction of the number of points required to represent a digitized line or
#'   its caricature." Cartographica 10, 112-122.
#'   \doi{10.3138/FM57-6770-U75U-7727}
#' @examples
#' str(world_map)
#' length(unique(world_map$region))
#' orb_worldmap()
"world_map"
