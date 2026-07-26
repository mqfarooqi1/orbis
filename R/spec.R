#' Start a plot
#'
#' `orb()` creates a plot specification: it records the data and the mapping
#' from variables to visual channels. Layers, labels, scales and themes are
#' added with `+`. Nothing is drawn until the plot is printed or saved, so a
#' specification is cheap to build and modify.
#'
#' Mappings are given as bare column names, in the style of a formula-free
#' grammar: `orb(df, x = wt, y = mpg, colour = cyl)`. The recognised channels
#' are `x`, `y`, `colour` (or `color`), `fill`, `size`, `label`, `group` and
#' `tooltip`.
#'
#' @param data A data frame.
#' @param ... Aesthetic mappings, given as `channel = column`.
#' @return An object of class `orb_spec`.
#' @seealso [orb_points()], [orb_line()], [orb_bars()], [orb_area()],
#'   [orb_map()], [orb_save()], [orb_interactive()]
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg, colour = cyl) + orb_points()
#' p
#' @export
orb <- function(data, ...) {
  if (!is.data.frame(data)) .stop("`data` must be a data frame.")
  structure(
    list(data = data, mapping = .capture_mapping(...), layers = list(),
         labs = list(), theme = orb_theme_light(), scales = list(),
         coord = list(type = "cartesian"), opts = list()),
    class = "orb_spec")
}

#' @keywords internal
#' @noRd
.capture_mapping <- function(...) {
  q <- as.list(substitute(list(...)))[-1L]
  nm <- names(q)
  if (is.null(nm)) nm <- rep("", length(q))
  nm[nm == "color"] <- "colour"
  names(q) <- nm
  q[nzchar(nm)]
}

#' @keywords internal
#' @noRd
.eval_mapping <- function(mapping, data) {
  out <- list()
  for (nm in names(mapping)) {
    v <- try(eval(mapping[[nm]], data, parent.frame(3)), silent = TRUE)
    if (inherits(v, "try-error")) {
      .stop("Cannot find `", deparse(mapping[[nm]]), "` in the data.")
    }
    out[[nm]] <- v
  }
  out
}

#' Add layers, scales, labels and themes to a plot
#'
#' The `+` operator assembles a plot from parts, in the tradition of a layered
#' grammar of graphics.
#'
#' @param e1 An `orb_spec` object.
#' @param e2 A layer, scale, theme, labels or coordinate object to add.
#' @return An `orb_spec` object.
#' @examples
#' orb(mtcars, x = wt, y = mpg) + orb_points() + orb_theme_dark()
#' @export
`+.orb_spec` <- function(e1, e2) {
  if (inherits(e2, "orb_layer")) {
    e1$layers <- c(e1$layers, list(e2))
  } else if (inherits(e2, "orb_theme")) {
    e1$theme <- e2
  } else if (inherits(e2, "orb_labs")) {
    e1$labs <- utils::modifyList(e1$labs, unclass(e2))
  } else if (inherits(e2, "orb_scale")) {
    e1$scales[[e2$channel]] <- e2
  } else if (inherits(e2, "orb_coord")) {
    e1$coord <- unclass(e2)
  } else if (inherits(e2, "orb_opts")) {
    e1$opts <- utils::modifyList(e1$opts, unclass(e2))
  } else {
    .stop("Cannot add an object of class ", class(e2)[1], " to a plot.")
  }
  e1
}

#' Axis, legend and plot labels
#'
#' @param title Plot title.
#' @param subtitle Plot subtitle.
#' @param x,y Axis titles.
#' @param colour,fill,size Legend titles for those channels.
#' @param caption Caption shown under the plot.
#' @return An object of class `orb_labs`, to be added to a plot.
#' @examples
#' orb(mtcars, x = wt, y = mpg) + orb_points() +
#'   orb_labs(title = "Fuel use", x = "Weight", y = "Miles per gallon")
#' @export
orb_labs <- function(title = NULL, subtitle = NULL, x = NULL, y = NULL,
                     colour = NULL, fill = NULL, size = NULL, caption = NULL) {
  structure(Filter(Negate(is.null),
                   list(title = title, subtitle = subtitle, x = x, y = y,
                        colour = colour, fill = fill, size = size,
                        caption = caption)),
            class = "orb_labs")
}

#' Plot-level options
#'
#' @param legend Should a legend be drawn when a colour, fill or size mapping
#'   is present? Default `TRUE`.
#' @param grid One of `"both"`, `"x"`, `"y"` or `"none"`.
#' @param interactive Should the SVG output embed interactive behaviour
#'   (tooltips, hover highlighting, zoom, pan and legend toggling)? Default
#'   `TRUE`. Raster output is unaffected.
#' @return An object of class `orb_opts`, to be added to a plot.
#' @examples
#' orb(mtcars, x = wt, y = mpg) + orb_points() + orb_options(grid = "y")
#' @export
orb_options <- function(legend = NULL, grid = NULL, interactive = NULL) {
  structure(Filter(Negate(is.null),
                   list(legend = legend, grid = grid, interactive = interactive)),
            class = "orb_opts")
}

#' @export
print.orb_spec <- function(x, ...) {
  n_layer <- length(x$layers)
  cat("<orb_spec>\n")
  cat("  data:   ", nrow(x$data), " rows x ", ncol(x$data), " columns\n", sep = "")
  cat("  mapping:", paste(names(x$mapping), collapse = ", "), "\n")
  cat("  layers: ", if (n_layer) paste(vapply(x$layers, function(l) l$geom,
                                              character(1)), collapse = " + ")
                    else "(none)", "\n")
  if (n_layer > 0) .display(x)
  invisible(x)
}
