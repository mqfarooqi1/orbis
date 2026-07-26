#' Visual themes
#'
#' Themes control the non-data appearance of a plot: colours of the background,
#' grid, axes and text, plus base font size. Add a theme to a plot with `+`.
#'
#' @param base_size Base font size in points (default 12).
#' @param ... Named theme elements to override, for example
#'   `panel = "#111111"` or `grid = "#333333"`. Recognised elements are
#'   `bg`, `panel`, `grid`, `axis`, `text`, `title`, `accent`, `base_size` and
#'   `font`.
#' @return An object of class `orb_theme`, to be added to a plot.
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg) + orb_points()
#' p + orb_theme_dark()
#' p + orb_theme_light(base_size = 14)
#' @name orb_theme
NULL

#' @keywords internal
#' @noRd
.theme_defaults <- function() {
  list(
    bg = "#FFFFFF", panel = "#FFFFFF", grid = "#E9ECEF",
    axis = "#868E96", text = "#495057", title = "#212529",
    accent = "#4C6EF5", base_size = 12,
    font = "system-ui, -apple-system, 'Segoe UI', Helvetica, Arial, sans-serif"
  )
}

#' @keywords internal
#' @noRd
.new_theme <- function(x) structure(x, class = "orb_theme")

#' @rdname orb_theme
#' @export
orb_theme_light <- function(base_size = 12, ...) {
  .new_theme(utils::modifyList(
    utils::modifyList(.theme_defaults(), list(base_size = base_size)),
    list(...)))
}

#' @rdname orb_theme
#' @export
orb_theme_dark <- function(base_size = 12, ...) {
  .new_theme(utils::modifyList(
    utils::modifyList(.theme_defaults(), list(
      bg = "#14161A", panel = "#14161A", grid = "#2B3038",
      axis = "#6C757D", text = "#ADB5BD", title = "#F1F3F5",
      accent = "#4DABF7", base_size = base_size)),
    list(...)))
}

#' @rdname orb_theme
#' @export
orb_theme_minimal <- function(base_size = 12, ...) {
  .new_theme(utils::modifyList(
    utils::modifyList(.theme_defaults(), list(
      grid = "#F1F3F5", axis = "#CED4DA", base_size = base_size)),
    list(...)))
}

#' @rdname orb_theme
#' @export
orb_theme_ink <- function(base_size = 12, ...) {
  .new_theme(utils::modifyList(
    utils::modifyList(.theme_defaults(), list(
      bg = "#FBF7F0", panel = "#FBF7F0", grid = "#E3DAC9",
      axis = "#8A7E6D", text = "#4A423A", title = "#2B241D",
      accent = "#B7472A", base_size = base_size)),
    list(...)))
}
