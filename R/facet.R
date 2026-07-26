#' Split a plot into small multiples
#'
#' Faceting draws one panel per level of a grouping variable, laid out in a
#' grid. Comparing many small panels that share a scale is often clearer than
#' overplotting every group in one panel.
#'
#' @param by Bare column name to facet by, for example `orb_facet(cyl)`.
#' @param ncol Number of columns in the grid. The default chooses a roughly
#'   square arrangement.
#' @param scales Whether panels share their axes: `"fixed"` (the default, so
#'   panels are directly comparable), `"free_x"`, `"free_y"` or `"free"`.
#' @return An object of class `orb_facet`, to be added to a plot.
#' @examples
#' orb(mtcars, x = wt, y = mpg) + orb_points() + orb_facet(cyl)
#' orb(mtcars, x = wt, y = mpg) + orb_points() +
#'   orb_facet(cyl, ncol = 3, scales = "free")
#' @export
orb_facet <- function(by, ncol = NULL, scales = c("fixed", "free_x", "free_y",
                                                  "free")) {
  scales <- match.arg(scales)
  structure(list(by = substitute(by), ncol = ncol, scales = scales),
            class = "orb_facet")
}
