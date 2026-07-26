#' @keywords internal
#' @noRd
.layer <- function(geom, mapping, data, params) {
  structure(list(geom = geom, mapping = mapping, data = data, params = params),
            class = "orb_layer")
}

#' Point layer
#'
#' Draws one mark per observation: a scatter plot, or a bubble chart when a
#' `size` mapping is present.
#'
#' @param ... Aesthetic mappings for this layer only, as `channel = column`.
#' @param data Optional data frame overriding the plot data.
#' @param size Point radius in pixels when `size` is not mapped (default 3.2).
#' @param colour Fixed colour used when the `colour` channel is not mapped.
#' @param fill Fixed fill used when the `fill` channel is not mapped.
#' @param alpha Opacity between 0 and 1.
#' @param stroke Outline width in pixels.
#' @return An object of class `orb_layer`.
#' @examples
#' orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points(alpha = 0.85)
#' @export
orb_points <- function(..., data = NULL, size = 3.2, colour = NULL,
                       fill = NULL, alpha = 0.9, stroke = 0.8) {
  .layer("points", .capture_mapping(...), data,
         list(size = size, colour = colour, fill = fill, alpha = alpha,
              stroke = stroke))
}

#' Line layer
#'
#' Connects observations in the order they appear, optionally split by a
#' `group` or `colour` mapping.
#'
#' @inheritParams orb_points
#' @param width Line width in pixels.
#' @param smooth Draw a smoothed curve through the points instead of straight
#'   segments (a Catmull-Rom style spline). Default `FALSE`.
#' @return An object of class `orb_layer`.
#' @examples
#' df <- data.frame(t = 1:50, v = cumsum(rnorm(50)))
#' orb(df, x = t, y = v) + orb_line(width = 2, smooth = TRUE)
#' @export
orb_line <- function(..., data = NULL, width = 1.8, colour = NULL,
                     alpha = 1, smooth = FALSE) {
  .layer("line", .capture_mapping(...), data,
         list(width = width, colour = colour, alpha = alpha, smooth = smooth))
}

#' Bar layer
#'
#' Draws one bar per observation. `x` may be discrete (a factor or character
#' column) or continuous. Bars start at zero.
#'
#' @inheritParams orb_points
#' @param width Bar width as a fraction of the available slot (0-1).
#' @param horizontal Draw horizontal bars. Default `FALSE`.
#' @return An object of class `orb_layer`.
#' @examples
#' df <- data.frame(g = c("a", "b", "c"), v = c(3, 7, 5))
#' orb(df, x = g, y = v, fill = g) + orb_bars()
#' @export
orb_bars <- function(..., data = NULL, width = 0.72, fill = NULL,
                     colour = NULL, alpha = 0.95, horizontal = FALSE) {
  .layer("bars", .capture_mapping(...), data,
         list(width = width, fill = fill, colour = colour, alpha = alpha,
              horizontal = horizontal))
}

#' Area layer
#'
#' Fills the region between a line and a baseline.
#'
#' @inheritParams orb_points
#' @param baseline Value the area is filled down to (default 0).
#' @param smooth Draw a smoothed upper boundary. Default `FALSE`.
#' @return An object of class `orb_layer`.
#' @examples
#' df <- data.frame(t = 1:40, v = abs(cumsum(rnorm(40))))
#' orb(df, x = t, y = v) + orb_area(alpha = 0.5) + orb_line()
#' @export
orb_area <- function(..., data = NULL, fill = NULL, alpha = 0.45,
                     baseline = 0, smooth = FALSE) {
  .layer("area", .capture_mapping(...), data,
         list(fill = fill, alpha = alpha, baseline = baseline, smooth = smooth))
}

#' Text layer
#'
#' Draws a text label at each observation.
#'
#' @inheritParams orb_points
#' @param size Font size in points.
#' @param dy Vertical offset in pixels (negative moves up).
#' @return An object of class `orb_layer`.
#' @examples
#' df <- data.frame(x = 1:3, y = c(2, 4, 3), n = c("a", "b", "c"))
#' orb(df, x = x, y = y, label = n) + orb_points() + orb_text(dy = -10)
#' @export
orb_text <- function(..., data = NULL, size = 10, colour = NULL, dy = 0,
                     alpha = 1) {
  .layer("text", .capture_mapping(...), data,
         list(size = size, colour = colour, dy = dy, alpha = alpha))
}

#' World map layer
#'
#' Draws country polygons from the built-in [world_map] dataset, or from a data
#' frame of your own with `long`, `lat` and `group` columns. The projection is
#' set with [orb_coord_map()]; if none is given, an equirectangular projection
#' is used.
#'
#' To build a choropleth, supply `values`: a data frame with a region column
#' and a value column, matched to map regions by name.
#'
#' @param data Optional polygon data frame with columns `long`, `lat`, `group`
#'   and (optionally) `region`. Defaults to [world_map].
#' @param values Optional data frame giving one value per region, used to fill
#'   the polygons.
#' @param region_col,value_col Column names in `values` holding the region name
#'   and the numeric value.
#' @param fill Fixed fill colour used when `values` is not supplied.
#' @param colour Border colour.
#' @param width Border width in pixels.
#' @param alpha Opacity between 0 and 1.
#' @param palette Continuous palette used for the choropleth; see
#'   [orb_palettes()].
#' @param na_fill Fill colour for regions with no value.
#' @param ocean Optional colour for the sea drawn behind the land: a disc for
#'   the orthographic globe, the panel background otherwise.
#' @return An object of class `orb_layer`.
#' @seealso [orb_coord_map()], [world_map]
#' @examples
#' orb_worldmap()
#'
#' vals <- data.frame(region = c("Brazil", "India", "France"), v = c(3, 9, 5))
#' orb(world_map) + orb_map(values = vals, region_col = "region",
#'                          value_col = "v") + orb_coord_map("robinson")
#' @export
orb_map <- function(data = NULL, values = NULL, region_col = "region",
                    value_col = NULL, fill = "#DEE2E6", colour = "#FFFFFF",
                    width = 0.4, alpha = 1, palette = "viridis",
                    na_fill = "#E9ECEF", ocean = NULL) {
  .layer("map", list(), data,
         list(values = values, region_col = region_col, value_col = value_col,
              fill = fill, colour = colour, width = width, alpha = alpha,
              palette = palette, na_fill = na_fill, ocean = ocean))
}

#' Point layer positioned by longitude and latitude
#'
#' Places points on a map using the active projection. Use inside a plot that
#' also has an [orb_map()] layer, mapping `x` to longitude and `y` to latitude.
#'
#' @inheritParams orb_points
#' @return An object of class `orb_layer`.
#' @examples
#' cities <- data.frame(long = c(2.35, -74, 151.2), lat = c(48.86, 40.7, -33.87),
#'                      pop = c(11, 19, 5))
#' orb(cities, x = long, y = lat, size = pop) +
#'   orb_map() + orb_points(colour = "#F76707") + orb_coord_map("robinson")
#' @export
orb_geo_points <- function(..., data = NULL, size = 4, colour = "#F76707",
                           alpha = 0.9, stroke = 0.8) {
  .layer("geo_points", .capture_mapping(...), data,
         list(size = size, colour = colour, alpha = alpha, stroke = stroke))
}

#' A ready-made world map
#'
#' A convenience wrapper that returns a complete world map plot, optionally
#' shaded by a value per region.
#'
#' @param values,region_col,value_col Passed to [orb_map()] to build a
#'   choropleth.
#' @param projection Projection name; see [orb_coord_map()].
#' @param palette Continuous palette name; see [orb_palettes()].
#' @param ocean Optional sea colour; see [orb_map()].
#' @param title Optional plot title.
#' @return An `orb_spec` object.
#' @examples
#' orb_worldmap(projection = "orthographic")
#' @export
orb_worldmap <- function(values = NULL, region_col = "region",
                         value_col = NULL, projection = "equirectangular",
                         palette = "viridis", ocean = NULL, title = NULL) {
  p <- orb(orbis::world_map) +
    orb_map(values = values, region_col = region_col, value_col = value_col,
            palette = palette, ocean = ocean) +
    orb_coord_map(projection)
  if (!is.null(title)) p <- p + orb_labs(title = title)
  p
}
