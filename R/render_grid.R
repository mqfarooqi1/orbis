## Render a scene through R's grid graphics, so a plot can be written to any
## device (PNG, TIFF, PDF, ...) at any resolution.

#' @keywords internal
#' @noRd
.grid_alpha <- function(col, alpha) {
  if (is.null(col) || is.na(col)) return(NA)
  if (is.null(alpha) || is.na(alpha) || alpha >= 1) return(col)
  v <- grDevices::col2rgb(col)
  grDevices::rgb(v[1], v[2], v[3], alpha * 255, maxColorValue = 255)
}

#' @keywords internal
#' @noRd
.render_grid <- function(sc) {
  grid::grid.newpage()
  vp <- grid::viewport(xscale = c(0, sc$width), yscale = c(sc$height, 0))
  grid::pushViewport(vp)
  on.exit(grid::popViewport(), add = TRUE)
  fs <- 0.75  # px -> pt

  for (m in sc$marks) {
    a <- m$alpha
    if (m$type == "rect") {
      grid::grid.rect(x = grid::unit(m$x + m$w / 2, "native"),
                      y = grid::unit(m$y + m$h / 2, "native"),
                      width = grid::unit(max(m$w, 0), "native"),
                      height = grid::unit(max(m$h, 0), "native"),
                      gp = grid::gpar(fill = .grid_alpha(m$fill, a),
                                      col = .grid_alpha(m$stroke, a),
                                      lwd = (m$sw %||% 1) * 0.75))
    } else if (m$type == "circle") {
      grid::grid.circle(x = grid::unit(m$x, "native"),
                        y = grid::unit(m$y, "native"),
                        r = grid::unit(m$r, "native"),
                        gp = grid::gpar(fill = .grid_alpha(m$fill, a),
                                        col = .grid_alpha(m$stroke, a),
                                        lwd = (m$sw %||% 1) * 0.75))
    } else if (m$type == "line") {
      grid::grid.lines(x = grid::unit(c(m$x1, m$x2), "native"),
                       y = grid::unit(c(m$y1, m$y2), "native"),
                       gp = grid::gpar(col = .grid_alpha(m$stroke, a),
                                       lwd = (m$sw %||% 1) * 0.75))
    } else if (m$type == "path") {
      if (length(m$xs) < 2) next
      if (isTRUE(m$closed)) {
        grid::grid.polygon(x = grid::unit(m$xs, "native"),
                           y = grid::unit(m$ys, "native"),
                           gp = grid::gpar(fill = .grid_alpha(m$fill, a),
                                           col = .grid_alpha(m$stroke, a),
                                           lwd = (m$sw %||% 1) * 0.75))
      } else {
        grid::grid.lines(x = grid::unit(m$xs, "native"),
                         y = grid::unit(m$ys, "native"),
                         gp = grid::gpar(col = .grid_alpha(m$stroke, a),
                                         lwd = (m$sw %||% 1) * 0.75,
                                         lineend = "round", linejoin = "round"))
      }
    } else if (m$type == "text") {
      hj <- switch(m$anchor %||% "start", start = 0, middle = 0.5, end = 1, 0)
      grid::grid.text(m$text, x = grid::unit(m$x, "native"),
                      y = grid::unit(m$y, "native"), hjust = hj, vjust = 0.72,
                      rot = m$rotate %||% 0,
                      gp = grid::gpar(col = .grid_alpha(m$fill, a),
                                      fontsize = m$size * fs,
                                      fontface = if (!is.null(m$weight)) "bold" else "plain"))
    }
  }
  invisible(NULL)
}

#' Draw a plot on the current graphics device
#'
#' Renders through R's grid graphics, so the plot appears on whatever device is
#' active. [orb_save()] is usually more convenient.
#'
#' @param plot An `orb_spec` object.
#' @param width,height Logical size in pixels.
#' @return `NULL`, invisibly. Called for its side effect.
#' @examples
#' p <- orb(mtcars, x = wt, y = mpg) + orb_points()
#' f <- tempfile(fileext = ".png")
#' grDevices::png(f, width = 820, height = 520)
#' orb_draw(p)
#' grDevices::dev.off()
#' unlink(f)
#' @export
orb_draw <- function(plot, width = 820, height = 520) {
  if (!inherits(plot, "orb_spec")) .stop("`plot` must be an orb_spec object.")
  .render_grid(.build(plot, width, height))
}
